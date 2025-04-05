import 'package:podsink/models/episode.dart';

class Podcast {
  int? id;
  final String name;
  final String artistName;
  final String feedUrl;
  final String? coverUrl;
  String? coverFilePath;
  final String? description;
  List<Episode> episodes = [];

  Podcast({this.id, required this.artistName, required this.feedUrl, this.coverUrl, this.coverFilePath, required this.name, this.description});

  // Convert Podcast to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'artist_name': artistName,
      'feed_url': feedUrl,
      'cover_url': coverUrl,
      'cover_filepath': coverFilePath,
      'description': description,
    };
  }

  // Convert Map to Podcast
  factory Podcast.fromMap(Map<String, dynamic> map) {
    return Podcast(
      id: map['id'],
      artistName: map['artist_name'] as String,
      feedUrl: map['feed_url'] as String,
      coverUrl: map['cover_url'] as String?,
      coverFilePath: map['cover_filepath'] as String?,
      name: map['name'] as String,
      description: map['description']
    );
  }
}