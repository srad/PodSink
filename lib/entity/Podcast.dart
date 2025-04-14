import 'package:floor/floor.dart';

@Entity(indices: [Index(value: ['feed_url'], unique: true)])
class Podcast {
  @primaryKey
  final int podcastId;
  final String name;
  final String artistName;
  final String feedUrl;
  final String? coverUrl;
  final String? coverFilePath;
  final String? description;

  Podcast(this.podcastId, this.name, this.artistName, this.feedUrl, this.coverUrl, this.coverFilePath, this.description);
}
