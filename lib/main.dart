// main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:podsink/models/episode.dart';
import 'package:podsink/models/podcast.dart';
import 'package:podsink/my_audio_handler.dart';
import 'package:podsink/screens/about.dart';
import 'package:podsink/screens/settings.dart';
import 'package:podsink/theme_provider.dart';
import 'package:podsink/services/version_service.dart';
import 'package:podsink/screens/add_podcast.dart';
import 'package:podsink/screens/episode_list.dart';
import 'package:podsink/screens/podcast_search.dart';
import 'package:podsink/screens/podcasts_list.dart';
import 'package:podsink/screens/player.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the Audio Handler BEFORE runApp
  final audioHandler = await initAudioService(); // Get the instance

  runApp(
    // Provide the AudioHandler instance to the widget tree
    Provider<AudioHandler>(
      create: (_) => audioHandler, // Provide the initialized handler
      // Optional: If the audioHandler itself might be replaced (unlikely here),
      // you might need a different Provider type or strategy.
      // For a single, long-lived service, basic Provider is fine.
      // dispose: (_, handler) => handler.stop(), // Optional: Handle disposal if needed, but AudioService manages its lifecycle
      child: ChangeNotifierProvider(create: (_) => ThemeProvider(), child: PodSink()),
    ),
  );
}

class PodSink extends StatefulWidget {
  const PodSink({super.key});

  @override
  State<StatefulWidget> createState() => _PodSink();
}

class _PodSink extends State<PodSink> {
  Future<AudioHandler>? _initAudioFuture;

  final lightTheme = ThemeData(brightness: Brightness.light, primaryColor: Colors.indigo, appBarTheme: AppBarTheme(backgroundColor: Colors.deepPurpleAccent, foregroundColor: Colors.white));

  final darkTheme = ThemeData(brightness: Brightness.dark, primaryColor: Colors.indigo, appBarTheme: AppBarTheme(backgroundColor: Colors.deepPurpleAccent, foregroundColor: Colors.white));

  @override
  void initState() {
    super.initState();
    _initAudioFuture = _initializeAudioService();
    // Don't block build, run async after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isAndroid) {
        checkForAndroidUpdate(); // Use in_app_update for Android
      } else if (Platform.isIOS) {
        // Use upgrader, new_version_plus, or your API check for iOS
        checkVersion(context);
        // or checkMyApiAndUpdate(context);
      }
      // Or use a cross-platform solution always:
      // checkVersion(context); // Using new_version_plus
      // Or trigger upgrader via its widget structure
    });
  }

  // Wrap the actual init in a separate async function
  Future<AudioHandler> _initializeAudioService() async {
    print("Attempting to initialize AudioService...");
    // Maybe add a small artificial delay IF the direct call still fails
    // await Future.delayed(Duration(milliseconds: 100));
    try {
      final handler = await initAudioService(); // Your original init function
      print("AudioService initialized successfully.");
      return handler;
    } catch (e, s) {
      print("Error during delayed initAudioService: $e\n$s");
      // Rethrow to let the FutureBuilder handle the error display
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AudioHandler>(
      future: _initAudioFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            // SUCCESS: Provide the handler and show the real app
            return Provider<AudioHandler>(
              create: (_) => snapshot.data!,
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return _create(themeProvider);
                },
              ),
            );
          } else if (snapshot.hasError) {
            // FAILURE: Show error message
            return MaterialApp(home: Scaffold(body: Center(child: Text('Error initializing audio service: ${snapshot.error}'))));
          }
        }
        // LOADING: Show a loading indicator
        return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
      },
    );
  }

  MaterialApp _create(ThemeProvider themeProvider) {
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
    );
  }
}
