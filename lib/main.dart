// main.dart
import 'package:flutter/material.dart';
import 'package:podsink/models/episode.dart';
import 'package:podsink/models/podcast.dart';
import 'package:podsink/theme_provider.dart';
import 'package:podsink/widgets/add_podcast.dart';
import 'package:podsink/widgets/episode_list.dart';
import 'package:podsink/widgets/podcast_search.dart';
import 'package:podsink/widgets/podcasts_list.dart';
import 'package:podsink/widgets/player.dart';
import 'package:podsink/widgets/settings.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => ThemeProvider(), child: PodSink()),
  );
}

class PodSink extends StatelessWidget {
  PodSink({super.key});

  final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.indigo,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.deepPurpleAccent,
      foregroundColor: Colors.white,
    ),
  );

  final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.indigo,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.deepPurpleAccent,
      foregroundColor: Colors.white,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'PodSink',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => PodcastListScreen(),
            '/add': (context) => AddPodcastScreen(),
            '/episodes': (context) {
              final podcast =
                  ModalRoute.of(context)!.settings.arguments as Podcast;
              return EpisodeListScreen(podcast: podcast);
            },
            '/player': (context) {
              final episode =
                  ModalRoute.of(context)!.settings.arguments as Episode;
              return PlayerScreen(episode: episode);
            },
            '/settings': (context) => SettingsScreen(),
            '/search': (context) => PodcastSearchScreen(),
          },
        );
      },
    );
  }
}
