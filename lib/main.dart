// main.dart
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podsink/models/episode.dart';
import 'package:podsink/models/podcast.dart';
import 'package:podsink/my_audio_handler.dart';
import 'package:podsink/screens/about.dart';
import 'package:podsink/theme_provider.dart';
import 'package:podsink/screens/add_podcast.dart';
import 'package:podsink/screens/episode_list.dart';
import 'package:podsink/screens/podcast_search.dart';
import 'package:podsink/screens/podcasts_list.dart';
import 'package:podsink/screens/player.dart';
import 'package:podsink/screens/settings.dart';
import 'package:podsink/widgets/floating_player.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is initialized

  await initAudioService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AudioHandler>(
          create: (_) => MyAudioHandler(), // Replace MyAudioHandler with your implementation
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const PodSink(),
    ),
  );
}

class PodSink extends StatefulWidget {
  const PodSink({super.key});

  @override
  State<StatefulWidget> createState() => _PodSink();
}

class _PodSink extends State<PodSink> {
  final lightTheme = ThemeData(brightness: Brightness.light, primaryColor: Colors.indigo, appBarTheme: AppBarTheme(backgroundColor: Colors.deepPurpleAccent, foregroundColor: Colors.white));

  final darkTheme = ThemeData(brightness: Brightness.dark, primaryColor: Colors.indigo, appBarTheme: AppBarTheme(backgroundColor: Colors.deepPurpleAccent, foregroundColor: Colors.white));

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final audioHandler = context.read<AudioHandler>();

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
          final podcast = ModalRoute.of(context)!.settings.arguments as Podcast;
          return EpisodeListScreen(podcast: podcast);
        },
        '/player': (context) {
          final episode = ModalRoute.of(context)!.settings.arguments as Episode;
          return PlayerScreen(episode: episode);
        },
        '/settings': (context) => SettingsScreen(),
        '/search': (context) => PodcastSearchScreen(),
        '/about': (context) => AboutScreen(),
      },
      builder: (context, child) {
        final audioHandler = context.read<AudioHandler>();

        return StreamBuilder<PlaybackState>(
          stream: audioHandler?.playbackState ?? Stream.empty(),
          builder: (context, snapshot) {
            final playbackState = snapshot.data;
            final isPlaying = playbackState?.playing ?? false;

            return Stack(
              children: [
                child!,
                if (isPlaying)
                  FloatingAudioPlayer(
                    onTap: () {
                      // Handle tap, e.g., navigate to the audio player screen
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
