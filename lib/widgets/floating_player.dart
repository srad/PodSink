import 'package:flutter/material.dart';

class FloatingAudioPlayer extends StatelessWidget {
  final VoidCallback onTap;

  FloatingAudioPlayer({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 48.0,
      right: 16.0,
      left: 16,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.play_arrow, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Podcast Title",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.more_vert, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
