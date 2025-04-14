import 'package:floor/floor.dart';
import 'package:podsink/entity/Episode.dart';
import 'package:podsink/entity/Podcast.dart';

@dao
abstract class PodcastDao {
  @Query('SELECT * FROM Podcast ORDER BY name')
  Stream<List<Podcast>> findAllPodcasts();

  @Query('SELECT * FROM Podcast WHERE id = :id')
  Stream<Podcast?> findPodcastById(int id);

  @insert
  Future<void> addPodcast(Podcast podcast);

Future<Podcast> addPodcast2(Podcast podcast) async {
  final db = await this.db;

  // This random name is later used for caching.
  podcast.coverFilePath = generateRandomFileName("jpg");
  final id = await db.insert(tablePodcasts, podcast.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

  podcast.id = id;

  return podcast;
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