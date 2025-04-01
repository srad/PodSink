import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:podsink/utils/podcast_feed_parser.dart';
import 'package:xml/xml.dart'; // For parsing RSS feeds

class EpisodesSearchScreen extends StatefulWidget {
  final String rssFeedUrl;

  EpisodesSearchScreen({required this.rssFeedUrl});

  @override
  _EpisodesSearchScreenState createState() => _EpisodesSearchScreenState();
}

class _EpisodesSearchScreenState extends State<EpisodesSearchScreen> {
  late Future<FeedPodcast> _podcastFuture;
  final PodcastFeedParser _parser = PodcastFeedParser();

  @override
  void initState() {
    super.initState();
    _podcastFuture = _parser.parsePodcastFeed(widget.rssFeedUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Episodes')),
      body: FutureBuilder<FeedPodcast>(
        future: _podcastFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.episodes.isEmpty) {
            return const Center(child: Text('No episodes found.'));
          }

          final podcast = snapshot.data!;
          return ListView.builder(
            itemCount: podcast.episodes.length,
            itemBuilder: (context, index) {
              final episode = podcast.episodes[index];

              return ListTile(
                leading: CachedNetworkImage(
                  placeholder:
                      (context, url) => const SizedBox(
                        width: 50,
                        height: 50,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  errorWidget:
                      (context, url, error) =>
                          const Icon(Icons.broken_image_outlined, size: 50),
                  imageUrl: episode.episodeImageUrl ?? podcast.imageUrl,
                  // Fallback to podcast cover image
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  episode.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  episode.pubDate,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/player', arguments: episode);
                },
              );
            },
          );
        },
      ),
    );
  }
}
