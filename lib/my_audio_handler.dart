import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';

AudioHandler? _audioHandler;

Future<AudioHandler> initAudioService() async {
  if (_audioHandler != null) {
    return _audioHandler!;
  }

  _audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
        fastForwardInterval: Duration(seconds: 30),
        rewindInterval: Duration(seconds: 30),
      )
  );

  return _audioHandler!;
}

class MyAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  final BehaviorSubject<List<MediaItem>> _queue = BehaviorSubject<List<MediaItem>>.seeded(const []);
  final BehaviorSubject<MediaItem?> _mediaItem = BehaviorSubject<MediaItem?>.seeded(null);

  Duration? duration;

  MyAudioHandler() {
    // Combine player state, position, buffered position, and duration
    Rx.combineLatest4<PlayerState, Duration, Duration, Duration?, PlaybackState>(_player.playerStateStream, _player.positionStream, _player.bufferedPositionStream, _player.durationStream, (playerState, position, bufferedPosition, duration) {
      final playing = playerState.playing;
      final processingState = switch (playerState.processingState) {
        ProcessingState.idle => AudioProcessingState.idle,
        ProcessingState.loading => AudioProcessingState.loading,
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.ready => AudioProcessingState.ready,
        ProcessingState.completed => AudioProcessingState.completed,
      };
      return PlaybackState(controls: [MediaControl.skipToPrevious, if (playing) MediaControl.pause else MediaControl.play, MediaControl.skipToNext], systemActions: const {MediaAction.seek}, androidCompactActionIndices: const [0, 1, 2], processingState: processingState, playing: playing, updatePosition: position, bufferedPosition: bufferedPosition, speed: _player.speed, queueIndex: queue.value.isEmpty ? null : _player.currentIndex);
    }).pipe(playbackState);

    // Update mediaItem duration
    _player.durationStream.listen((duration) {
      final currentMediaItem = _mediaItem.valueOrNull;
      if (currentMediaItem != null) {
        _mediaItem.add(currentMediaItem.copyWith(duration: duration));
      }
    });

    // Forward the local queue and mediaItem streams
    queue.addStream(_queue);
    mediaItem.addStream(_mediaItem);
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem, {bool playAutomatically = true}) async {
    try {
      duration = await _player.setUrl(mediaItem.id);
      _mediaItem.add(mediaItem.copyWith(duration: duration)); // Set media item after loading URL
      if (playAutomatically) {
        await play();
      }
    } catch (e) {
      print("❌ Error loading media: $e");
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
          errorMessage: e.toString(), // Consider a more structured error object
        ),
      );
    }
  }

  @override
  Future<void> play() async {
    _player.play();
  }

  @override
  Future<void> pause() async {
    _player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
      case AudioServiceRepeatMode.group: // Not supported by just_audio
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    _player.setShuffleModeEnabled(shuffleMode == AudioServiceShuffleMode.all);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    _mediaItem.add(mediaItem);
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await playbackState.firstWhere((state) => state.processingState == AudioProcessingState.idle);
    await super.stop();
  }

  @override
  Future<void> onTaskRemoved() async {
    if (!_player.playing) await stop();
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
    _queue.close();
    _mediaItem.close();
  }

  @override
  Future<void> setQueue(List<MediaItem> queue) async {
    _queue.add(queue);
    if (queue.isNotEmpty) {
      try {
        await _player.setAudioSource(ConcatenatingAudioSource(children: queue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList()), initialIndex: 0, initialPosition: Duration.zero);
        _mediaItem.add(queue.first);
      } catch (e) {
        print("Error loading queue: $e");
        playbackState.add(playbackState.value.copyWith(processingState: AudioProcessingState.error, errorMessage: 'Failed to load queue: $e'));
      }
    } else {
      await _player.stop();
      _mediaItem.add(null);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < _queue.value.length) {
      try {
        await _player.seek(Duration.zero, index: index);
        _mediaItem.add(_queue.value[index]);
      } catch (e) {
        print("Error skipping to queue item: $e");
        playbackState.add(playbackState.value.copyWith(processingState: AudioProcessingState.error, errorMessage: 'Failed to skip to item: $e'));
      }
    }
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final newQueue = [..._queue.value, mediaItem];
    _queue.add(newQueue);
    final audioSource = AudioSource.uri(Uri.parse(mediaItem.id));
    if (_player.audioSource is ConcatenatingAudioSource) {
      (_player.audioSource as ConcatenatingAudioSource).add(audioSource);
    } else if (_player.audioSource == null) {
      try {
        await _player.setAudioSource(ConcatenatingAudioSource(children: [audioSource]));
        _mediaItem.add(mediaItem);
      } catch (e) {
        print("Error adding first queue item: $e");
        playbackState.add(playbackState.value.copyWith(processingState: AudioProcessingState.error, errorMessage: 'Failed to add first item: $e'));
      }
    }
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index >= 0 && index < _queue.value.length) {
      final newQueue = [..._queue.value];
      final removedItem = newQueue.removeAt(index);
      _queue.add(newQueue);
      if (_player.audioSource is ConcatenatingAudioSource) {
        try {
          await (_player.audioSource as ConcatenatingAudioSource).removeAt(index);
          if (newQueue.isEmpty) {
            await _player.stop();
            _mediaItem.add(null);
          } else if (_player.currentIndex == index) {
            if (newQueue.isNotEmpty) {
              await skipToQueueItem(0); // Or handle based on your desired behavior
            } else {
              _mediaItem.add(null);
            }
          } else if (_player.currentIndex! > index) {
            // The index of the currently playing item has shifted
          } else {
            _mediaItem.add(newQueue[_player.currentIndex!]);
          }
        } catch (e) {
          print("Error removing queue item: $e");
          playbackState.add(playbackState.value.copyWith(processingState: AudioProcessingState.error, errorMessage: 'Failed to remove item: $e'));
        }
      } else if (newQueue.isEmpty) {
        await _player.stop();
        _mediaItem.add(null);
      }
    }
  }
}
