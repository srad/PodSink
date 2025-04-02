import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

// Must be a top-level function or static method
Future<AudioHandler> initAudioService() async {
  if (Platform.isAndroid) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.example.podsink',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    );
  }

  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.podsink', // Unique ID
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  MediaItem? _lastPlayedItem;

  MyAudioHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    // Listen for completion to potentially advance queue or stop service
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        // Optional: Auto-advance logic if you have a queue
        // skipToNext();
        // Or just stop if it's the end
        stop(); // Or perhaps just pause() depending on desired behavior
      }
    });
  }

  // --- Corrected Custom Method ---

  Future<void> loadEpisode(MediaItem item) async {
    mediaItem.add(item); // Broadcast the new item
    _lastPlayedItem = item; // Store it
    try {
      // --- CORRECTION HERE ---
      // Parse the item.id (which should be the URL string) into a Uri
      final audioUri = Uri.parse(item.id);
      await _player.setAudioSource(AudioSource.uri(audioUri));
      // No need to call play() here automatically unless intended.
      // Let the UI trigger play().
    } on Exception catch (e) {
      print("Error parsing Uri from item.id ('${item.id}'): $e");
      // Handle error: broadcast an error state, show a message, etc.
      playbackState.addError("Invalid audio URL format.");
      // Optionally stop playback if something was playing before
      await stop();
    } catch (e) {
      print("Error loading audio source: $e");
      // Handle other errors during loading
      playbackState.addError("Failed to load audio.");
      await stop();
    }
  }

  // --- Overridden Methods (Play, Pause, Seek, Stop, etc. remain the same) ---

  @override
  Future<void> play() async {
    // Check if we have a source loaded OR if we can load the last one
    if (_player.audioSource != null || _lastPlayedItem != null) {
      // If not loaded, try loading last item first
      if (_player.audioSource == null && _lastPlayedItem != null) {
        await loadEpisode(_lastPlayedItem!);
        // Check again if loading succeeded before playing
        if (_player.audioSource == null) {
          print("Cannot play: Failed to load last known item.");
          return; // Don't try to play if loading failed
        }
      }
      // Now play
      await _player.play();
    } else {
      print("Cannot play: No audio item loaded.");
      // Maybe broadcast a message to the UI?
    }
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    // Reset the media item in the UI when stopped completely
    mediaItem.add(null);
    // Ensure the state reflects idle after stop completes
    await playbackState.firstWhere(
      (state) => state.processingState == AudioProcessingState.idle || state.processingState == AudioProcessingState.completed, // Handle case where stop is called right after completion
    );
  }

  @override
  Future<void> skipToNext() async {
    print("Skip to next requested (implement queue logic if needed)");
  }

  @override
  Future<void> skipToPrevious() async {
    print("Skip to previous requested (implement queue logic if needed)");
    await seek(Duration.zero); // Default: restart current track
  }

  // --- Helper & Transform Method (remain the same) ---
  PlaybackState _transformEvent(PlaybackEvent event) {
    // Make sure to handle the null mediaItem case gracefully in controls
    final currentItem = mediaItem.value;
    final controls = <MediaControl>[
      // Queue controls (add if you implement queueing)
      // MediaControl.skipToPrevious,

      // Core controls depend on state
      if (_player.playing) MediaControl.pause else MediaControl.play,
      MediaControl.stop,

      // Queue controls (add if you implement queueing)
      // MediaControl.skipToNext,
    ];
    // Determine which compact actions to show (e.g., Play/Pause, maybe Skip)
    final compactActionIndices =
        [
          if (_player.playing) controls.indexOf(MediaControl.pause) else controls.indexOf(MediaControl.play),
          // Add indices for skip buttons if they are always present in `controls`
        ].where((i) => i != -1).toList(); // Filter out -1 if a control isn't present

    return PlaybackState(
      controls: controls,
      systemActions: const {
        // Actions available via system (notifications, lock screen)
        MediaAction.seek,
        MediaAction.seekForward, // Often mapped to next track by OS
        MediaAction.seekBackward, // Often mapped to previous track by OS
        // Add MediaAction.playPause, MediaAction.play, MediaAction.pause if needed explicitly
        // Add MediaAction.skipToNext, MediaAction.skipToPrevious if queueing
      },
      androidCompactActionIndices: compactActionIndices,
      processingState: _mapProcessingState(_player.processingState),
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex, // Handle this if you implement a queue
      // Ensure mediaItem is associated with the state
      // mediaItem: currentItem, // This line is often not needed as mediaItem stream is separate
    );
  }

  AudioProcessingState _mapProcessingState(ProcessingState processingState) {
    // ... (mapping remains the same)
    switch (processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        // You might want a default or error state
        return AudioProcessingState.error; // Or throw exception
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await _player.dispose();
    await super.onTaskRemoved();
  }
}
