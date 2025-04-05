import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class FeedPodcast {
  final String title;
  final String description;
  final String link;
  final String imageUrl;
  final String feedUrl;
  final List<FeedEpisode> episodes;
  final String author;

  FeedPodcast({required this.title, required this.description, required this.link, required this.imageUrl, required this.feedUrl, required this.episodes, required this.author});
}

class FeedEpisode {
  final String title;
  final String description;
  final String mediaUrl;
  final String pubDate;
  String? imageUrl;
  String? meta;
  String? duration;

  FeedEpisode({required this.title, required this.duration, required this.description, required this.mediaUrl, required this.pubDate, this.imageUrl});
}

class PodcastFeedParser {
  Future<FeedPodcast> parsePodcastFeed(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load podcast feed');
    }

    final document = XmlDocument.parse(response.body);

    // Look for podcast metadata
    final channelTitle = document.findAllElements('channel').firstOrNull?.findAllElements('title').firstOrNull?.innerText;
    final channelDescription = document.findAllElements('channel').firstOrNull?.findAllElements('description').firstOrNull?.innerText;
    final channelLink = document.findAllElements('channel').firstOrNull?.findAllElements('link').firstOrNull?.innerText;
    final channelAuthor = document.findAllElements('channel').firstOrNull?.findAllElements('itunes:author').firstOrNull?.innerText;
    final channelImageUrl = document.findAllElements('channel').firstOrNull?.findAllElements('image').firstOrNull?.findAllElements('url').firstOrNull?.innerText;
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
      final String? duration = item.findAllElements('itunes:duration').firstOrNull?.innerText.trim();

      if (audioUrl == null) continue;

      episodes.add(FeedEpisode(title: episodeTitle ?? "Title", description: episodeDescription ?? "Description", mediaUrl: audioUrl, pubDate: pubDate ?? "no date", imageUrl: episodeImageUrl, duration: duration));
    }

    return FeedPodcast(title: channelTitle ?? "Title missing", author: channelAuthor ?? "No author", description: channelDescription ?? "Description missing", link: channelLink ?? "https://example.com", imageUrl: channelImageUrl ?? '', feedUrl: feedUrl, episodes: episodes);
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}