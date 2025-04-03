import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:podsink/screens/episodes_search.dart';

class PodcastSearchScreen extends StatefulWidget {
  const PodcastSearchScreen({super.key});

  @override
  _PodcastSearchScreenState createState() => _PodcastSearchScreenState();
}

class _PodcastSearchScreenState extends State<PodcastSearchScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  List<dynamic> _searchResults = [];

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
          final data = jsonDecode(response.body);
          setState(() {
            _searchResults = data['results'];
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
                        final podcast = _searchResults[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6.0), // Rounded corners for the image
                            child: CachedNetworkImage(placeholder: (context, url) => const SizedBox(width: 50, height: 50, child: Center(child: CircularProgressIndicator())), errorWidget: (context, url, error) => const Icon(Icons.broken_image_outlined, size: 50), imageUrl: podcast['artworkUrl60'], width: 50, height: 50, fit: BoxFit.cover),
                          ),
                          title: Text(podcast['collectionName'] ?? 'No Title'),
                          subtitle: Text(podcast['artistName'] ?? 'No Artist'),
                          onTap: () {
                            // Navigate to the Episodes screen
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EpisodesSearchScreen(rssFeedUrl: podcast['feedUrl']!)));
                          },
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
}
