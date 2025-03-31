// episode_list_screen.dart
import 'package:flutter/material.dart';
import 'package:podsink/models/episode.dart';
import 'package:podsink/models/podcast.dart';
import 'package:podsink/services/db_service.dart';

class EpisodeListScreen extends StatefulWidget {
  final Podcast podcast;

  EpisodeListScreen({required this.podcast});

  @override
  _EpisodeListScreenState createState() => _EpisodeListScreenState();
}

class _EpisodeListScreenState extends State<EpisodeListScreen> {
  List<Episode>? _episodes;

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    final dbService = DBService();
    final episodes = await dbService.getEpisodesByPodcast(widget.podcast.id!);
    setState(() => _episodes = episodes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.podcast.title)),
      body: ListView.builder(
        itemCount: _episodes?.length ?? 0,
        itemBuilder: (context, index) {
          final episode = _episodes![index];
          return ListTile(
            title: Text(episode.title),
            subtitle: Text(episode.audioUrl),
            onTap:
                () =>
                    Navigator.pushNamed(context, '/player', arguments: episode),
          );
        },
      ),
    );
  }
}
