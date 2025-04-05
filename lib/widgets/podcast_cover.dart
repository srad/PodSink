import 'package:flutter/material.dart';
import 'dart:io';

import 'package:podsink/utils/cover_download.dart';

class PodcastCover extends StatefulWidget {
  final String imageUrl; // URL of the cover image to download
  final String coverName; // Name to save the cover image

  const PodcastCover({super.key, required this.imageUrl, required this.coverName});

  @override
  _PodcastCoverState createState() => _PodcastCoverState();
}

class _PodcastCoverState extends State<PodcastCover> {
  late Future<File> _coverImageFile;

  @override
  void initState() {
    super.initState();
    // Start downloading and resizing the cover image when the widget is initialized
    _coverImageFile = _downloadCoverImage(widget.imageUrl, widget.coverName);
  }

  // This function downloads the image, resizes it, and saves it locally
  Future<File> _downloadCoverImage(String imageUrl, String coverName) async {
    return await CoverDownloader.downloadAndResizePodcastCoverImage(imageUrl, coverName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Podcast Cover')),
      body: Center(
        child: FutureBuilder<File>(
          future: _coverImageFile, // The file to display
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Loading indicator while downloading
            } else if (snapshot.hasError) {
              return Icon(Icons.heart_broken_outlined);
              //return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return Image.file(snapshot.data!); // Display the resized image from local storage
            } else {
              return Icon(Icons.broken_image_outlined);
            }
          },
        ),
      ),
    );
  }
}
