import 'package:podsink/models/episode.dart';
import 'package:podsink/models/podcast.dart';
import 'package:podsink/services/db_service.dart';
import 'package:podsink/utils/podcast_feed_parser.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart';

class PodcastService {
  final DBService dbService;
  final PodcastFeedParser parser;

  PodcastService(this.dbService, this.parser);

  Future<Podcast?> savePodcastsWithEpisodes(final String feedUrl) async {
    // Get the RSS feed directly. This is NO iTunes search result or something!
    final result = await parser.parsePodcastFeed(feedUrl);
    final dbService = DBService();
    final podcast = Podcast(
      id: null,
      // Auto-increment
      name: result.title,
      artistName: result.author,
      coverUrl: result.imageUrl,
      feedUrl: result.feedUrl,
    );
    final insertedPodcast = await dbService.addPodcast(podcast);
    if (insertedPodcast != null) {
      for (var episode in result.episodes) {
        await dbService.addEpisode(Episode(trackName: episode.title, podcast: insertedPodcast, audioUrl: episode.mediaUrl, coverUrl: episode.imageUrl));
      }

      return insertedPodcast;
    }

    return null;
  }

  Future<Podcast?> getPodcastWithEpisodes(final int podcastId) async {
    final podcast = await dbService.getPodcastById(podcastId);
    if (podcast != null) {
      podcast.episodes = await dbService.getEpisodesByPodcast(podcastId);
      return podcast;
    }
    return null;
  }

  /// TODO:
  updatePodcast(Podcast podcast) {
    print("TODO update");
  }

  /*
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
            trackName: titleElement.innerText,
            audioFilePath: linkElement.getAttribute('url')!,
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
   */
}
