import 'package:podsink/models/podcast.dart';

class Episode {
  int? id;
  final String title;
  final String audioUrl;
  final Podcast podcast;

  Episode({
    this.id,
    required this.title,
    required this.audioUrl,
    required this.podcast,
  });

  // Convert Episode to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'audio_url': audioUrl,
      'podcast_id': podcast.id,
    };
  }

  // Convert Map to Episode
  factory Episode.fromMap(Map<String, dynamic> map) {
    return Episode(
      id: map['id'],
      title: map['title'] as String,
      audioUrl: map['audio_url'] as String,
      podcast: Podcast(
        id: map['podcast_id'],
        title: '', // Placeholder for now
        feedUrl: '', // Placeholder for now
      ),
    );
  }
}
