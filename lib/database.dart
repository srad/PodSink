import 'package:floor/floor.dart';
import 'package:podsink/dao/dao/episode_dao.dart';
import 'package:podsink/dao/dao/podcast_dao.dart';

import 'entity/Podcast.dart';
import 'entity/Episode.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Podcast, Episode])
abstract class AppDatabase extends FloorDatabase {
  PodcastDao get podcastDao;
  EpisodeDao get episodeDao;
}