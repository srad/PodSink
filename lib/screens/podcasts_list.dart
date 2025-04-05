import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:podsink/services/podcast_service.dart';
import 'package:podsink/widgets/app_drawer.dart';
import 'package:podsink/models/podcast.dart';
import 'package:podsink/services/db_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class PodcastListScreen extends StatefulWidget {
  const PodcastListScreen({super.key});

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
    if (podcast.id != null) {
      try {
        await dbService.destroyPodcast(podcast.id!);
        setState(() {
          _podcasts = _podcasts?.where((element) => element.id != podcast.id!).toList() ?? [];
        });
      } catch (e) {
        AlertDialog(title: Text("Error deleting podcast"), content: Text('$e'));
      }
    }
  }

  Future<void> _updatePodcast(Podcast podcast) async {
    final service = Provider.of<PodcastService>(context);
    await service.updatePodcast(podcast);
    _loadPodcasts(); // Reload the list after updating
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Podcasts'), Icon(Icons.podcasts)]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 15,
        children: [
          FloatingActionButton(
            child: Icon(Icons.add, size: 28),
            onPressed: () async {
              final podcast = await Navigator.pushNamed(context, '/add') as Podcast?;
              if (podcast != null) {
                await _loadPodcasts();
              }
            },
          ),
          FloatingActionButton(
            onPressed: () async {
              final podcast = await Navigator.pushNamed(context, '/search') as Podcast?;
              if (podcast != null) {
                await _loadPodcasts();
              }
            },
            tooltip: "Add podcast",
            child: const Icon(Icons.search, size: 28),
          ),
        ],
      ),
      drawer: AppDrawer(),
      appBar: _appBar(context),
      body: Container(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0), child: _podcasts != null && _podcasts!.isNotEmpty ? _podcastList(context) : Center(child: Text("No Podcasts yet", style: TextStyle(fontSize: 24)))),
    );
  }

  _podcastList(BuildContext context) {
    return ListView.builder(
      itemCount: _podcasts?.length ?? 0,
      itemBuilder: (context, index) {
        final podcast = _podcasts![index];
        return Dismissible(
          confirmDismiss: (direction) => confirm(context, title: Text("Delete?")),
          // Step 1
          key: Key(_podcasts![index].id.toString()),
          onDismissed: (direction) async {
            await _removePodcast(podcast);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('dismissed')));
          },
          child: ListTile(
            leading: SizedBox(
              width: 50, // Adjust this based on your requirement
              height: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                // Optional, for rounded corners
                child: CachedNetworkImage(
                  imageUrl: "https://picsum.photos/seed/picsum/200/150",
                  imageBuilder:
                      (context, imageProvider) => Image(
                        image: imageProvider,
                        fit: BoxFit.fill, // Ensures the image fills the space while maintaining aspect ratio
                      ),
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            title: Text(podcast.artistName),
            subtitle: Text(podcast.feedUrl),
            trailing: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () async {
                if (await confirm(context, title: Text("Delete?"))) {
                  await _removePodcast(podcast);
                  setState(() {
                    _podcasts?.removeAt(index);
                  });
                }
              },
            ),
            onTap: () async {
              await Navigator.pushNamed(context, '/episodes', arguments: podcast);
            },
          ),
        );
      },
    );
  }
}
