// podcast_list_screen.dart
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:podsink/models/podcast.dart';
import 'package:podsink/services/db_service.dart';
import 'package:podsink/services/update_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PodcastListScreen extends StatefulWidget {
  @override
  _PodcastListScreenState createState() => _PodcastListScreenState();
}

// podcast_list_screen.dart
class _PodcastListScreenState extends State<PodcastListScreen> {
  List<Podcast>? _podcasts;

  @override
  void initState() {
    super.initState();
    _loadPodcasts();
  }

  Future<void> _loadPodcasts() async {
    final dbService = DBService();
    final podcasts = await dbService.getAllPodcasts();
    setState(() => _podcasts = podcasts);
  }

  Future<void> _removePodcast(Podcast podcast) async {
    final dbService = DBService();
    await dbService.destroyPodcast(podcast);
  }

  Future<void> _updatePodcast(Podcast podcast) async {
    final updateService = UpdateService();
    await updateService.updatePodcast(podcast);
    _loadPodcasts(); // Reload the list after updating
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final podcast =
              await Navigator.pushNamed(context, '/add') as Podcast?;
          if (podcast != null) {
            await _loadPodcasts();
          }
        },
        tooltip: "Add podcast",
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      appBar: AppBar(
        leading: Icon(Icons.podcasts),
        title: Text('PodSink - Podcasts'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        child:
            _podcasts != null && _podcasts!.isNotEmpty
                ? ListView.builder(
                  itemCount: _podcasts?.length ?? 0,
                  itemBuilder: (context, index) {
                    final podcast = _podcasts![index];
                    return Dismissible(
                      confirmDismiss:
                          (direction) =>
                              confirm(context, title: Text("Delete?")),
                      // Step 1
                      key: Key(_podcasts![index].id.toString()),
                      onDismissed: (direction) async {
                        await _removePodcast(podcast);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('dismissed')));
                      },
                      child: ListTile(
                        leading: SizedBox(
                          width: 50, // Adjust this based on your requirement
                          height: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            // Optional, for rounded corners
                            child: CachedNetworkImage(
                              imageUrl:
                                  "https://picsum.photos/seed/picsum/200/150",
                              imageBuilder:
                                  (context, imageProvider) => Image(
                                    image: imageProvider,
                                    fit:
                                        BoxFit
                                            .fill, // Ensures the image fills the space while maintaining aspect ratio
                                  ),
                              placeholder:
                                  (context, url) => CircularProgressIndicator(),
                              errorWidget:
                                  (context, url, error) => Icon(Icons.error),
                            ),
                          ),
                        ),
                        title: Text(podcast.title),
                        subtitle: Text(podcast.feedUrl),
                        trailing: IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () async {
                            if (await confirm(
                              context,
                              title: Text("Delete?"),
                            )) {
                              await _removePodcast(podcast);
                              setState(() {
                                _podcasts?.removeAt(index);
                              });
                            }
                          },
                        ),
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            '/episodes',
                            arguments: podcast,
                          );
                        },
                      ),
                    );
                  },
                )
                : Center(
                  child: Text(
                    "No Podcasts yet",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
      ),
    );
  }
}
