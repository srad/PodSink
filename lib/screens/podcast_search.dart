import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:podsink/models/ItunesItem.dart';
import 'package:podsink/models/podcast.dart';
import 'package:podsink/screens/episodes_search.dart';
import 'package:podsink/services/db_service.dart';

class PodcastSearchScreen extends StatefulWidget {
  const PodcastSearchScreen({super.key});

  @override
  _PodcastSearchScreenState createState() => _PodcastSearchScreenState();
}

class _SearchItem extends ItunesItem {
  int? podcastDataBaseId;
  bool subscribed = false;

  _SearchItem({required super.trackName, required super.artistName, required super.collectionName, required super.artworkUrl100, required super.feedUrl, this.subscribed = false});
}

class _PodcastSearchScreenState extends State<PodcastSearchScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  final _dbService = DBService();

  List<_SearchItem> _searchResults = [];

  @override
  void initState() {
    super.initState();

    // Add a post-frame callback to focus the input field after the page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Focus the input field after the page is built
      FocusScope.of(context).requestFocus(_focusNode);
      SystemChannels.textInput.invokeMethod('TextInput.show');
    });
  }

  // Function to search for podcasts via Apple Podcasts API
  Future<void> _searchPodcasts(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 700), () async {
      // Perform search operation here
      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
        });
        return;
      }

      final url = Uri.parse('https://itunes.apple.com/search?term=$query&media=podcast');

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          Map<String, dynamic> jsonResponse = jsonDecode(response.body);

          final itunesSearchResponse = ItunesSearchResponse.fromJson(jsonResponse);

          final results = await Future.wait(itunesSearchResponse.results.map((e) async {
            final subscribed = await _dbService.containsPodcastFeedUrl(e.feedUrl);
            return _SearchItem(
              trackName: e.trackName,
              artistName: e.artistName,
              collectionName: e.collectionName,
              artworkUrl100: e.artworkUrl100,
              feedUrl: e.feedUrl,
              subscribed: subscribed,
            );
          }).toList());

          setState(() {
            _searchResults = results;
          });
        } else {
          // Handle error
          print('Failed to load podcasts');
        }
      } catch (e) {
        print('Error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Podcasts')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              focusNode: _focusNode,
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search Podcasts',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchPodcasts(_controller.text);
                  },
                ),
              ),
              onChanged: (query) {
                _searchPodcasts(query);
              },
            ),
          ),
          Expanded(
            child:
                _searchResults.isEmpty
                    ? Center(child: Text('No results found'))
                    : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final searchItem = _searchResults[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6.0), // Rounded corners for the image
                            child: CachedNetworkImage(placeholder: (context, url) => const SizedBox(width: 50, height: 50, child: Center(child: CircularProgressIndicator())), errorWidget: (context, url, error) => const Icon(Icons.broken_image_outlined, size: 50), imageUrl: searchItem.artworkUrl100, width: 50, height: 50, fit: BoxFit.cover),
                          ),
                          title: Text(searchItem.collectionName),
                          subtitle: Text(searchItem.artistName),
                          onTap: () {
                            // Navigate to the Episodes screen
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EpisodesSearchScreen(rssFeedUrl: searchItem.feedUrl)));
                          },
                          trailing: _toggleSubscribe(searchItem.subscribed, searchItem),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the focus node and text controller
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _toggleSubscribe(bool subscribed, _SearchItem item) {
    if (!subscribed) {
      return IconButton(
        icon: Icon(Icons.add_circle_outline),
        onPressed: () async {
          try {
            final podcast = await _dbService.addPodcast(
                Podcast(
                    artistName: item.artistName,
                    feedUrl: item.feedUrl,
                    name: item.collectionName,
                    coverUrl: item.artworkUrl100)
            );

            setState(() {
              item.podcastDataBaseId = podcast.id;
              item.subscribed = true;
            });
          } catch (e) {

          }
        },
      );
    }
    return IconButton(
      icon: Icon(Icons.remove_circle_outline),
      onPressed: () async {
        final podcast = await _dbService.getPodcastByFeedUrl(item.feedUrl);
        if (podcast != null) {
          await _dbService.destroyPodcast(podcast.id!);
        }
      },
    );
  }
}
