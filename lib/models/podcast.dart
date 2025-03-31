class Podcast {
  int? id = null;
  final String title;
  final String feedUrl;

  Podcast({required this.id, required this.title, required this.feedUrl});

  // Convert Podcast to Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'feed_url': feedUrl};
  }

  // Convert Map to Podcast
  factory Podcast.fromMap(Map<String, dynamic> map) {
    return Podcast(
      id: map['id'],
      title: map['title'] as String,
      feedUrl: map['feed_url'] as String,
    );
  }
}
