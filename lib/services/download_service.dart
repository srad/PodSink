// download_service.dart
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:podsink/models/episode.dart';

class DownloadService {
  Future<void> downloadPodcast(Episode episode) async {
    final url = Uri.parse(episode.audioUrl);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${episode.trackName}.mp3');

    if (!await file.exists()) {
      final response = await HttpClient()
          .getUrl(url)
          .then((request) => request.close());
      await response.pipe(file.openWrite());

      print('File saved to ${file.path}');
    } else {
      print('File already exists');
    }
  }

  Future<File?> getDownloadedPodcast(Episode episode) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${episode.trackName}.mp3');

    return await file.exists() ? file : null;
  }
}
