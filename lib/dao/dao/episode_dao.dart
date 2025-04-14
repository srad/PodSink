import 'package:floor/floor.dart';
import 'package:podsink/entity/Episode.dart';

@dao
abstract class EpisodeDao {
  @Query('SELECT * FROM Episode')
  Future<List<Episode>> findAllEpisodes();

  @Query('SELECT * FROM Episode WHERE id = :id')
  Stream<Episode?> findEpisodeById(int id);

  @insert
  Future<void> addEpisode(Episode episode);

  @Query('SELECT * FROM Episode WHERE Podcast.id = :id')
  Future<List<Episode>> getEpisodesByPodcast(int id);
}