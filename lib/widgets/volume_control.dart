import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class VolumeControl extends StatefulWidget {
  final double initialVolume;
  final ValueChanged<double> onVolumeChanged; // Callback for external state management

  const VolumeControl({Key? key, this.initialVolume = 0.5, required this.onVolumeChanged}) : super(key: key);

  @override
  _VolumeControlState createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  late double _volume;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _volume = widget.initialVolume;
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _volume = _isMuted ? 0.0 : 0.5;
      widget.onVolumeChanged(_volume); // Notify parent
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up), onPressed: _toggleMute),
            Expanded(
              child: Slider(
                value: _volume,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                onChanged: (value) {
                  setState(() {
                    _volume = value;
                    _isMuted = _volume == 0.0;
                    widget.onVolumeChanged(_volume); // Notify parent
                  });
                },
              ),
            ),
          ],
        ),
        Text("Volume: ${(_volume * 100).toInt()}%"),
      ],
    );
  }
}
