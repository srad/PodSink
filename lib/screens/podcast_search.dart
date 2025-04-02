import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:podsink/screens/episodes_search.dart';

class PodcastSearchScreen extends StatefulWidget {
  const PodcastSearchScreen({super.key});

  @override
  _PodcastSearchScreenState createState() => _PodcastSearchScreenState();
}

class _PodcastSearchScreenState extends State<PodcastSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _searchResults = [];

  // Function to search for podcasts via Apple Podcasts API
  Future<void> _searchPodcasts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final url = Uri.parse(
      'https://itunes.apple.com/search?term=$query&media=podcast',
    );

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Podcasts')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
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
            Expanded(
              child:
                  _searchResults.isEmpty
                      ? Center(child: Text('No results found'))
                      : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final podcast = _searchResults[index];
                          return ListTile(
                            leading:
                                podcast['artworkUrl60'] != null
                                    ? Image.network(
                                      podcast['artworkUrl60'],
                                      width: 50,
                                      height: 50,
                                    )
                                    : Icon(Icons.podcasts),
                            title: Text(
                              podcast['collectionName'] ?? 'No Title',
                            ),
                            subtitle: Text(
                              podcast['artistName'] ?? 'No Artist',
                            ),
                            onTap: () {
                              // Navigate to the Episodes screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EpisodesSearchScreen(rssFeedUrl: podcast['feedUrl']!),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
