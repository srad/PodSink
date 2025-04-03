import 'package:flutter/material.dart';
import 'package:podsink/widgets/audio_controls.dart';

class FloatingAudioPlayer extends StatelessWidget {
  final VoidCallback onTap;

  const FloatingAudioPlayer({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 48.0,
      right: 16.0,
      left: 16.0,
      height: 140,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: AudioControls()
        ),
    );
  }
}
