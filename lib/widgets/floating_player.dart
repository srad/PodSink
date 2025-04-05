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
      height: 70,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF5E5A5A), // Light grey (top)
              Color(0xFF302E2E), // Slightly darker grey (bottom)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(120), // Subtle shadow
              blurRadius: 4,
              offset: Offset(0, 4), // Floating effect, shadow below
            ),
          ],
        ),
        child: Padding(padding: EdgeInsets.all(4), child: AudioControls(slider: false)),
      ),
    );
  }
}
