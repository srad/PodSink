import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:podsink/utils/date_time.dart';
import 'package:podsink/widgets/volume_control.dart';
import 'package:provider/provider.dart';

class SimpleAudioPlayer extends StatefulWidget {
  String? url;
  final bool playAutomatically;

  SimpleAudioPlayer({super.key, this.url, this.playAutomatically = true});

  @override
  State<SimpleAudioPlayer> createState() => _SimpleAudioPlayerState();
}

class _SimpleAudioPlayerState extends State<SimpleAudioPlayer> {
  bool _isHandlerLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.url != null) {
      _loadMedia(widget.url!);
    } else {
      _isHandlerLoaded = true;
    }
  }

  @override
  void didUpdateWidget(SimpleAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _isHandlerLoaded = false;
      _loadMedia(widget.url!);
    }
  }

  Future<void> _loadMedia(String url) async {
    final audioHandler = context.read<AudioHandler>();

    if (_isHandlerLoaded && audioHandler.mediaItem.value?.id == widget.url) {
      return;
    }

    final mediaItem = MediaItem(id: url, title: audioHandler.mediaItem.value?.title ?? "No title", duration: audioHandler.mediaItem.value?.duration, artUri: audioHandler.mediaItem.value?.artUri);

    if (widget.playAutomatically) {
      await audioHandler.playMediaItem(mediaItem);
    } else {
      await audioHandler.updateMediaItem(mediaItem);
    }

    if (mounted) {
      setState(() {
        _isHandlerLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioHandler = context.read<AudioHandler>();

    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, mediaItemSnapshot) {
        final mediaItem = mediaItemSnapshot.data;
        final duration = mediaItem?.duration ?? Duration.zero;

        if (mediaItem?.id != widget.url && _isHandlerLoaded) {
          return Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, playbackStateSnapshot) {
            final playbackState = playbackStateSnapshot.data;
            final processingState = playbackState?.processingState ?? AudioProcessingState.idle;
            final playing = playbackState?.playing ?? false;
            final position = playbackState?.updatePosition ?? Duration.zero;
            final buffered = playbackState?.bufferedPosition ?? Duration.zero;

            // Show loading indicator if still loading or not yet initialized
            if (!_isHandlerLoaded || processingState == AudioProcessingState.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (processingState == AudioProcessingState.error) {
              return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: ${playbackState?.errorMessage ?? 'Failed to load audio'}', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center)));
            }

            // Main UI showing the player controls
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: Row(
                    children: [
                      // Play/Pause button
                      _buildPlayPauseButton(context, processingState, playing),
                      // Show the current position of the audio
                      Text(durationToHHMMSS(position)),
                      Expanded(
                        child: Slider(
                          value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                          min: 0.0,
                          max: duration.inSeconds.toDouble(),
                          secondaryTrackValue: buffered.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                          onChanged: (value) {
                            // Seek functionality
                            if (duration > Duration.zero && processingState != AudioProcessingState.buffering) {
                              audioHandler.seek(Duration(seconds: value.round()));
                            }
                          },
                          activeColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      // Show total duration of the audio
                      Text(durationToHHMMSS(duration)),
                    ],
                  ),
                ),

                // VolumeControl(
                //   initialVolume: 1.0,
                //   onVolumeChanged: (value) async {
                //     print((value * 100).toInt());
                //     await audioHandler.androidSetRemoteVolume((value * 100).toInt());
                //   },
                // ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPlayPauseButton(BuildContext context, AudioProcessingState processingState, bool playing) {
    final audioHandler = context.read<AudioHandler>();

    if (processingState == AudioProcessingState.buffering || processingState == AudioProcessingState.loading) {
      return const SizedBox(height: 48, width: 48, child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)));
    } else {
      return IconButton(
        icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled),
        padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
        iconSize: 48.0,
        color: Theme.of(context).primaryColor,
        tooltip: playing ? 'Pause' : 'Play',
        onPressed: () {
          if (playing) {
            audioHandler.pause();
          } else {
            audioHandler.play();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
