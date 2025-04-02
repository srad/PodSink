// simple_audio_player.dart

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:provider/provider.dart';

class SimpleAudioPlayer extends StatefulWidget {
  final String url;
  final bool playAutomatically; // Optional: Control if playback starts immediately

  const SimpleAudioPlayer({
    super.key,
    required this.url,
    this.playAutomatically = false, // Default to not playing automatically
  });

  @override
  State<SimpleAudioPlayer> createState() => _SimpleAudioPlayerState();
}

class _SimpleAudioPlayerState extends State<SimpleAudioPlayer> {
  // No local player instance needed here!
  // State variables are now derived from the handler's streams

  // Flag to track if the initial load for this specific widget instance/URL is done
  // This prevents redundant load calls during rebuilds if the URL hasn't changed.
  bool _isHandlerLoaded = false;

  @override
  void initState() {
    super.initState();
    // Tell the handler to load the media when the widget is first created
    _loadMedia();
  }

  @override
  void didUpdateWidget(SimpleAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the URL passed to the widget changes, tell the handler to load the new one
    if (widget.url != oldWidget.url) {
      _isHandlerLoaded = false; // Reset loaded flag for the new URL
      _loadMedia();
    }
    // You might also want logic here if playAutomatically changes
  }

  // --- Media Loading ---

  Future<void> _loadMedia() async {
    final audioHandler = context.read()<AudioHandler>(); // Use read for accessing methods/streams
    // Avoid reloading if already loaded for this widget instance/URL
    if (_isHandlerLoaded && audioHandler.mediaItem.value?.id == widget.url) {
      return;
    }

    // Create a MediaItem for the handler
    final mediaItem = MediaItem(
      id: widget.url, // Use the URL as the unique ID
      // Provide some default metadata - ideally fetch real metadata if possible
      title: "Audio Track", // Placeholder title
      artist: "Unknown Artist", // Placeholder artist
      // artUri: Uri.parse('uri_to_album_art_if_available'),
    );

    // Tell the background handler to load this item.
    // Use playMediaItem if playAutomatically is true, otherwise updateMediaItem.
    if (widget.playAutomatically) {
      await audioHandler.playMediaItem(mediaItem);
    } else {
      // This prepares the item but doesn't start playback automatically
      await audioHandler.updateMediaItem(mediaItem);
      // We might need to ensure the player is ready in the handler
      // if updateMediaItem doesn't implicitly do a 'prepare'.
      // The current MyAudioHandler implementation implicitly prepares on open.
    }
    if (mounted) {
      setState(() {
        _isHandlerLoaded = true; // Mark as loaded for this URL
      });
    }
  }

  // --- Helper ---

  String _formatDuration(Duration? duration) {
    if (duration == null || duration.isNegative) {
      return '--:--';
    }
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final hoursString = twoDigits(hours);
    final minutesString = twoDigits(minutes);
    final secondsString = twoDigits(seconds);
    if (hours > 0) {
      return '$hoursString:$minutesString:$secondsString';
    } else {
      return '$minutesString:$secondsString';
    }
  }

  // --- Build Method (Listens to Handler Streams) ---

  @override
  Widget build(BuildContext context) {
    final audioHandler = context.read()<AudioHandler>(); // Use read for accessing methods/streams

    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, mediaItemSnapshot) {
        // Get the current MediaItem from the handler
        final mediaItem = mediaItemSnapshot.data;
        // Get duration from the handler's current MediaItem
        final duration = mediaItem?.duration ?? Duration.zero;

        // Only build the player UI if the handler's current item matches this widget's URL
        // This prevents the widget from showing controls for a different track if the
        // handler is playing something else loaded by another part of the app.
        if (mediaItem?.id != widget.url && _isHandlerLoaded) {
          // If loaded but URL mismatch, show loading or placeholder.
          // This might happen if another part of the app changed the track.
          return const Center(child: Text("Waiting for track...")); // Or CircularProgressIndicator
        }

        return StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, playbackStateSnapshot) {
            final playbackState = playbackStateSnapshot.data;
            final processingState = playbackState?.processingState ?? AudioProcessingState.idle;
            final playing = playbackState?.playing ?? false;
            final position = playbackState?.updatePosition ?? Duration.zero;
            final buffered = playbackState?.bufferedPosition ?? Duration.zero;

            // --- Handle Loading/Error States ---
            // Use _isHandlerLoaded to avoid showing loading briefly before the first load call completes
            if (!_isHandlerLoaded || processingState == AudioProcessingState.loading || (mediaItem?.id != widget.url)) {
              // Show loading if handler is loading OR if the mediaItem ID doesn't match our URL yet
              return const Center(child: CircularProgressIndicator());
            }

            if (processingState == AudioProcessingState.error) {
              return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: ${playbackState?.errorMessage ?? 'Failed to load audio'}', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center)));
            }

            // --- Main Player UI ---
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Play/Pause/Buffering Button (Uses handler state)
                    _buildPlayPauseButton(context, processingState, playing),
                    Text(_formatDuration(position)), // Position from handler
                    Expanded(
                      child: Slider(
                        value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                        min: 0.0,
                        max: duration > Duration.zero ? duration.inSeconds.toDouble() : 0.0,
                        // Duration from handler's mediaItem
                        secondaryTrackValue: buffered.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                        // Buffered position from handler
                        onChanged: (value) {
                          // Seek using the handler
                          if (duration > Duration.zero && processingState != AudioProcessingState.buffering) {
                            audioHandler.seek(Duration(seconds: value.round()));
                          }
                        },
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(_formatDuration(duration)), // Duration from handler's mediaItem
                  ],
                ),

                // You can add volume controls back if needed, calling _audioHandler.setVolume()
                // Note: media_kit handles system volume by default, UI controls might not be necessary
                // unless you want app-specific volume adjustment separate from system volume.
              ],
            );
          },
        );
      },
    );
  }

  // Helper widget for the button state
  Widget _buildPlayPauseButton(BuildContext context, AudioProcessingState processingState, bool playing) {
    // Show loading indicator if buffering or explicitly loading
    if (processingState == AudioProcessingState.buffering || processingState == AudioProcessingState.loading) {
      return const SizedBox(height: 48, width: 48, child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)));
    }
    // Show play/pause button otherwise
    else {
      return IconButton(
        icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled),
        padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
        iconSize: 48.0,
        color: Theme.of(context).primaryColor,
        tooltip: playing ? 'Pause' : 'Play',
        // Call handler methods on press
        onPressed: () {
          final audioHandler = context.read()<AudioHandler>(); // Use read for accessing methods/streams
          if (playing) {
            audioHandler.pause;
          } else {
            audioHandler.play;
          }
        },
      );
    }
  }

  @override
  void dispose() {
    // IMPORTANT: DO NOT dispose the handler here!
    // The handler lives longer than the widget.
    // We also don't dispose the player, as the handler owns it.
    // No local subscriptions to cancel either.
    super.dispose();
  }
}
