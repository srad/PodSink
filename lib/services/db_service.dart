import 'package:podsink/models/episode.dart';
import 'package:podsink/models/podcast.dart';
import 'package:podsink/utils/file_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class DBService {
  static const _databaseName = "Podcasts.db";
  static const _version = 1;
  static const tablePodcasts = 'podcasts';
  static const tableEpisodes = 'episodes';

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String filePath = path.join(documentsDirectory.path, _databaseName);
    return await openDatabase(filePath, version: _version, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablePodcasts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        feed_url TEXT NOT NULL UNIQUE,
        artist_name TEXT,
        cover_url TEXT,
        cover_filepath TEXT,
        description TEXT,
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableEpisodes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        track_name TEXT NOT NULL,
        audio_url TEXT NOT NULL,
        audio_filepath TEXT,
        cover_url TEXT,
        cover_filepath TEXT,
        description TEXT,
        podcast_id INTEGER NOT NULL,
        FOREIGN KEY(podcast_id) REFERENCES podcasts(id)
      )
    ''');
  }

  Future<List<Podcast>> getAllPodcasts() async {
    final db = await this.db;
    var result = await db.query(tablePodcasts, orderBy: "title");
    final podcasts = result.map((map) => Podcast.fromMap(map)).toList();

    return podcasts;
  }

  Future<Podcast> addPodcast(Podcast podcast) async {
    final db = await this.db;

    // This random name is later used for caching.
    podcast.coverFilePath = generateRandomFileName("jpg");
    final id = await db.insert(tablePodcasts, podcast.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    podcast.id = id;

    return podcast;
  }

  Future<List<Episode>> getEpisodesByPodcast(int podcastId) async {
    final db = await this.db;
    var result = await db.query(tableEpisodes, where: 'podcast_id = ?', whereArgs: [podcastId]);
    return result.map((map) => Episode.fromMap(map)).toList();
  }

  Future<Podcast?> getPodcastByFeedUrl(String feedUrl) async {
    final db = await this.db;
    var result = await db.query(tablePodcasts, where: 'feed_url = ?', whereArgs: [feedUrl]);

    if (result.isNotEmpty) {
      return Podcast.fromMap(result.first);
    }
    return null;
  }

  Future<Podcast?> getPodcastById(int id) async {
    final db = await this.db;
    var result = await db.query(tablePodcasts, where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return Podcast.fromMap(result.first);
    }
    return null;
  }

  Future<void> addEpisode(Episode episode) async {
    final db = await this.db;
    episode.coverFilePath = generateRandomFileName("jpg");
    await db.insert(tableEpisodes, episode.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> containsPodcastFeedUrl(String feedUrl) async {
    final db = await this.db;

    // Query the podcasts table for a matching feed_url
    var result = await db.query(tablePodcasts, where: 'feed_url = ?', whereArgs: [feedUrl]);

    // If the result is not empty, the feed URL exists
    return result.isNotEmpty;
  }

  destroyPodcast(int id) async {
    final db = await this.db;
    await db.delete(tablePodcasts, where: "id = ?", whereArgs: [id]);
  }
}
