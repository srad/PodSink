// update_service.dart
import 'package:http/http.dart' as http;
import 'package:podsink/models/episode.dart';
import 'package:podsink/models/podcast.dart';
import 'package:podsink/services/db_service.dart';
import 'package:xml/xml.dart';

class UpdateService {
  Future<void> updatePodcast(Podcast podcast) async {
    final response = await http.get(Uri.parse(podcast.feedUrl));
    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      for (final item in items) {
        final titleElement = item.findElements('title').first;
        final linkElement = item.findElements('enclosure').first;

        if (titleElement.innerText.isNotEmpty && linkElement.getAttribute('url') != null) {
          final episode = Episode(
            id: null, // Auto-increment
            title: titleElement.innerText,
            audioUrl: linkElement.getAttribute('url')!,
            podcast: podcast,
          );

          final dbService = DBService();
          await dbService.addEpisode(episode);
        }
      }
    } else {
      throw Exception('Failed to load podcasts');
    }
  }
}
