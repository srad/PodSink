import 'package:floor/floor.dart';

@entity
class Episode {
  @primaryKey
  final int id;
  final String trackName;
  final String audioUrl;
  final String? audioFilePath;
  final String? coverUrl;
  String? coverFilePath;
  final String? description;
  final String? publishDate;

  Episode(this.id, this.trackName, this.audioUrl, this.audioFilePath, this.coverUrl, this.description, this.publishDate);
}
