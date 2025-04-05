import 'dart:convert';

class ItunesSearchResponse {
  final int resultCount;
  final List<ItunesItem> results;

  ItunesSearchResponse({required this.resultCount, required this.results});

  // Factory method to create ItunesSearchResponse from JSON
  factory ItunesSearchResponse.fromJson(Map<String, dynamic> json) {
    return ItunesSearchResponse(
      resultCount: json['resultCount'],
      results: List<ItunesItem>.from(
        json['results'].map((item) => ItunesItem.fromJson(item)),
      ),
    );
  }
}

class ItunesItem {
  final String trackName;
  final String artistName;
  final String collectionName;
  final String artworkUrl100;
  final String feedUrl;

  ItunesItem({
    required this.trackName,
    required this.artistName,
    required this.collectionName,
    required this.artworkUrl100,
    required this.feedUrl,
  });

  // Factory method to create ItunesItem from JSON
  factory ItunesItem.fromJson(Map<String, dynamic> json) {
    return ItunesItem(
      trackName: json['trackName'] ?? '',
      artistName: json['artistName'] ?? '',
      collectionName: json['collectionName'] ?? '',
      artworkUrl100: json['artworkUrl100'] ?? '',
      feedUrl: json['feedUrl'] ?? '',
    );
  }
}
