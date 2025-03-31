// player_screen.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:podsink/models/episode.dart';
import 'package:podsink/services/download_service.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayerScreen extends StatefulWidget {
  final Episode episode;

  PlayerScreen({required this.episode});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

Future<void> checkStoragePermission() async {
  if (await Permission.storage.request().isGranted) {
    // Permission is granted, proceed with downloading.
    print('Storage permission granted');
  } else {
    // Handle the case where the user denied the permission.
    print('Storage permission denied');
  }
}

class _PlayerScreenState extends State<PlayerScreen> {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    await checkStoragePermission();
    if (await Permission.storage.status.isGranted) {
      final downloadService = DownloadService();
      final file = await downloadService.getDownloadedPodcast(widget.episode);

      if (file != null) {
        _audioPlayer = AudioPlayer();
        await _audioPlayer!.setSourceDeviceFile(file.path);
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer!.pause();
    } else {
      await _audioPlayer!.resume();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Podcast Player')),
      body: Center(
        child: ElevatedButton(
          onPressed: _togglePlayPause,
          child: Text(_isPlaying ? 'Pause' : 'Play'),
        ),
      ),
    );
  }
}
