import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:podsink/utils/date_time.dart';
import 'package:podsink/widgets/volume_control.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class AudioControls extends StatefulWidget {
  String? url;
  final bool playAutomatically;
  final bool slider;

  AudioControls({super.key, this.url, this.playAutomatically = true, this.slider = true});

  @override
  State<AudioControls> createState() => _AudioControlsState();
}

class _AudioControlsState extends State<AudioControls> {
  final Color _accentColor = Colors.white70;

  @override
  Widget build(BuildContext context) {
    final audioHandler = context.read<AudioHandler>();

    /// Combine mediaItem and playbackState streams
    final combinedStream = Rx.combineLatest2<MediaItem?, PlaybackState, Tuple2<MediaItem?, PlaybackState>>(audioHandler.mediaItem, audioHandler.playbackState, (mediaItem, playbackState) => Tuple2(mediaItem, playbackState));

    return StreamBuilder<Tuple2<MediaItem?, PlaybackState>>(
      stream: combinedStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: _accentColor));
        }

        final mediaItem = snapshot.data!.item1;
        final playbackState = snapshot.data!.item2;

        return Padding(padding: EdgeInsets.symmetric(vertical: 4, horizontal: 0), child: _buildControls(context, playbackState, mediaItem));
      },
    );
  }

  Widget _buildPlayPauseButton(BuildContext context, AudioProcessingState processingState, bool playing) {
    final audioHandler = context.read<AudioHandler>();

    return IconButton(
      icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled, color: _accentColor),
      padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
      iconSize: 48.0,
      color: Theme.of(context).primaryColor,
      onPressed: () {
        if (playing) {
          audioHandler.pause();
        } else {
          audioHandler.play();
        }
      },
    );
  }

  Widget _buildIconButton(BuildContext context, AudioProcessingState processingState, IconData icon, VoidCallback? onPressed) {
    return IconButton(icon: Icon(icon, color: _accentColor), iconSize: 38.0, color: Theme.of(context).primaryColor, onPressed: onPressed);
  }

  @override
  void dispose() {
    super.dispose();
  }

  _buildControls(BuildContext context, PlaybackState playbackState, MediaItem? mediaItem) {
    final fontStyle = TextStyle(fontSize: 18, color: _accentColor, decoration: TextDecoration.none);
    final isPlaying = playbackState?.playing ?? false;
    final duration = mediaItem?.duration ?? Duration.zero;
    final position = playbackState?.updatePosition ?? Duration.zero;
    final buffered = playbackState?.bufferedPosition ?? Duration.zero;
    final processingState = playbackState?.processingState;
    final audioHandler = context.read<AudioHandler>();

    if (processingState == AudioProcessingState.buffering || processingState == AudioProcessingState.loading) {
      return Center(child: CircularProgressIndicator(color: _accentColor, strokeWidth: 5.0));
    } else {
      return Column(
        children: [
          if (widget.slider)
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: Slider(
                  activeColor: _accentColor,
                  //activeColor: Theme.of(context).primaryColor,
                  value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  secondaryTrackValue: buffered.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                  onChanged: (value) {
                    // Seek functionality
                    if (duration > Duration.zero && playbackState.processingState != AudioProcessingState.buffering) {
                      audioHandler.seek(Duration(seconds: value.round()));
                    }
                  },
                ),
              ),
            ),
          Row(
            children: [
              Expanded(flex: 1, child: _buildPlayPauseButton(context, playbackState.processingState, isPlaying)),
              Expanded(flex: 2, child: Column(children: [Text("${durationToHHMMSS(position)}", style: fontStyle), Text("${durationToHHMMSS(duration)}", style: fontStyle)])),
              Row(
                children: [
                  _buildIconButton(context, playbackState.processingState, Icons.replay_30, () async {
                    await audioHandler.seekBackward(false);
                  }),
                  _buildIconButton(context, playbackState.processingState, Icons.forward_30, () async {
                    await audioHandler.seekForward(false);
                  }),
                  _buildIconButton(context, playbackState.processingState, Icons.close, () async {
                    await audioHandler.stop();
                  }),
                ],
              ),
            ],
          ),
        ],
      );
    }
  }
}
