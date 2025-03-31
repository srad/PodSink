// main.dart
import 'package:flutter/material.dart';
import 'package:podsink/models/episode.dart';
import 'package:podsink/models/podcast.dart';
import 'package:podsink/widgets/add_podcast.dart';
import 'package:podsink/widgets/episode_list.dart';
import 'package:podsink/widgets/list_podcasts.dart';
import 'package:podsink/widgets/player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PodSink',
      theme: ThemeData(primarySwatch: Colors.blue, appBarTheme: AppBarTheme(color: Colors.indigoAccent, foregroundColor: Colors.white)),
      initialRoute: '/',
      routes: {
        '/': (context) => PodcastListScreen(),
        '/add': (context) => AddPodcastScreen(),
        '/episodes': (context) {
          final podcast = ModalRoute.of(context)!.settings.arguments as Podcast;
          return EpisodeListScreen(podcast: podcast);
        },
        '/player': (context) {
          final episode = ModalRoute.of(context)!.settings.arguments as Episode;
          return PlayerScreen(episode: episode);
        },
      },
    );
  }
}
