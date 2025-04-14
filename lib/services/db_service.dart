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

}
