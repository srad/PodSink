import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class FeedPodcast {
  final String title;
  final String description;
  final String link;
  final String imageUrl;
  final String feedUrl;
  final List<FeedEpisode> episodes;

  FeedPodcast({
    required this.title,
    required this.description,
    required this.link,
    required this.imageUrl,
    required this.feedUrl,
    required this.episodes,
  });
}

class FeedEpisode {
  final String title;
  final String description;
  final String audioUrl;
  final String pubDate;
  String? episodeImageUrl;

  FeedEpisode({
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.pubDate,
    this.episodeImageUrl,
  });
}

class PodcastFeedParser {
  Future<FeedPodcast> parsePodcastFeed(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load podcast feed');
    }

    final parseFormat = "E, dd MMM yyyy HH:mm:ss zzz";
    final document = XmlDocument.parse(response.body);

    // Look for podcast metadata
    final channelTitle = document.findAllElements('channel').firstOrNull?.findAllElements('title').firstOrNull?.innerText;
    final channelDescription = document.findAllElements('channel').firstOrNull?.findAllElements('description').firstOrNull?.innerText;
    final channelLink =  document.findAllElements('channel').firstOrNull?.findAllElements('link').firstOrNull?.innerText;
    final channelImageUrl =  document.findAllElements('channel').firstOrNull?.findAllElements('image').firstOrNull?.findAllElements('url').firstOrNull?.innerText;
    final feedUrl = url;

    // Parsing episodes
    List<FeedEpisode> episodes = [];
    final items = document.findAllElements('item');

    for (var item in items) {
      final episodeTitle = item.findAllElements('title').firstOrNull?.innerText.trim();
      final episodeDescription = item.findAllElements('description').firstOrNull?.innerText.trim();
      final audioUrl = item.findAllElements('enclosure').firstOrNull?.getAttribute('url')?.trim();
      final pubDate = item.findAllElements('pubDate').firstOrNull?.innerText.replaceAll("00:00:00", "").replaceAll("+0000", "").trim();
      final String? episodeImageUrl = item.findAllElements('itunes:image').firstOrNull?.getAttribute('href')?.trim();

      if (audioUrl == null) continue;

      episodes.add(
        FeedEpisode(
          title: episodeTitle ?? "Title",
          description: episodeDescription ?? "Description",
          audioUrl: audioUrl,
          pubDate: pubDate ?? "no date",
          episodeImageUrl: episodeImageUrl
        ),
      );
    }

    return FeedPodcast(
      title: channelTitle ?? "Title missing",
      description: channelDescription ?? "Description missing",
      link: channelLink ?? "https://example.com",
      imageUrl: channelImageUrl ?? '',
      feedUrl: feedUrl,
      episodes: episodes,
    );
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
