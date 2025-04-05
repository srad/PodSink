import 'package:podsink/models/podcast.dart';

class Episode {
  int? id;
  final String trackName;
  final String audioUrl;
  final Podcast podcast;
  final String? audioFilePath;
  final String? coverUrl;
  String? coverFilePath;
  final String? description;

  Episode({
    this.id,
    required this.trackName,
    this.audioFilePath,
    required this.podcast,
    this.coverUrl,
    this.coverFilePath,
    required this.audioUrl,
    this.description
  });

  // Convert Episode to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'track_name': trackName,
      'audio_url': audioUrl,
      'audio_filepath': audioFilePath,
      'podcast_id': podcast.id,
      'cover_url': coverUrl,
      'cover_filepath': coverFilePath,
      'description': description
    };
  }

  // Convert Map to Episode
  factory Episode.fromMap(Map<String, dynamic> map) {
    return Episode(
      id: map['id'],
      trackName: map['title'] as String,
      audioUrl: map['audio_url'] as String,
      audioFilePath: map['audio_filepath'] as String?,
      coverUrl: map['cover_url'] as String?,
      coverFilePath: map['cover_filepath'] as String?,
      description: map['description'] as String?,

      podcast: Podcast(
        id: map['podcast_id'],
        name: map['name'],
        artistName: map['artist_name'],
        coverFilePath: map['cover_filepath'],
        coverUrl: map['cover_url'],
        feedUrl: map['feed_url'],
      ),
    );
  }
}
