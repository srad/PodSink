import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podsink/utils/podcast_feed_parser.dart';
import 'package:podsink/widgets/simple_audio_player.dart';
import 'package:provider/provider.dart';

class EpisodesSearchScreen extends StatefulWidget {
  final String rssFeedUrl;

  const EpisodesSearchScreen({super.key, required this.rssFeedUrl});

  @override
  _EpisodesSearchScreenState createState() => _EpisodesSearchScreenState();
}

class _EpisodesSearchScreenState extends State<EpisodesSearchScreen> {
  late Future<FeedPodcast> _podcastFuture;
  FeedEpisode? _selectedEpisode;
  final PodcastFeedParser _parser = PodcastFeedParser();

  @override
  void initState() {
    super.initState();
    _podcastFuture = _parser.parsePodcastFeed(widget.rssFeedUrl);
  }

  Card _info(FeedPodcast podcast) {
    final textTheme = Theme
        .of(context)
        .textTheme;
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    return Card(
      elevation: 2.0,
      // Adjust elevation for shadow intensity
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      // Add margins if needed outside the card
      clipBehavior: Clip.antiAlias,
      // Ensures content respects card's rounded corners
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
              children: [
                // --- Album Art ---
                SizedBox(
                  width: 80.0, // Fixed width for the image
                  height: 80.0, // Fixed height for the image
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.0), // Rounded corners for the image
                    child: CachedNetworkImage(imageUrl: _selectedEpisode == null ? podcast.imageUrl : _selectedEpisode?.imageUrl ?? "", placeholder: (context, url) => const SizedBox(width: 80, height: 80, child: Center(child: CircularProgressIndicator())), errorWidget: (context, url, error) => const Icon(Icons.broken_image_outlined, size: 50)),
                  ),
                ),

                const SizedBox(width: 12.0), // Spacing between image and text/controls
                // --- Text Info and Controls ---
                Expanded(
                  // Allows this column to take remaining horizontal space
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align text left
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space out content vertically if needed
                    children: [
                      // --- Episode Title ---
                      Text(
                        _selectedEpisode != null ? _selectedEpisode!.title : podcast.title,
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        //maxLines: 2, // Limit title to 2 lines
                        overflow: TextOverflow.visible, // Add '...' if title is too long
                      ),

                      const SizedBox(height: 4.0), // Spacing
                      // --- Podcast Name ---
                      _scrollBox(_selectedEpisode != null ? _selectedEpisode!.description : podcast.description, 150),
                    ],
                  ),
                ),
              ],
            ),
            // if (_selectedEpisode != null) Divider(),
            // if (_selectedEpisode != null)
            //   if (_selectedEpisode != null) SimpleAudioPlayer(url: _selectedEpisode!.mediaUrl),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Episodes')),
      body: FutureBuilder<FeedPodcast>(
        future: _podcastFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.episodes.isEmpty) {
            return const Center(child: Text('No episodes found.'));
          }

          final podcast = snapshot.data!;

          return Column(
            children: [
              _info(podcast),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: podcast.episodes.length,
                  itemBuilder: (context, index) {
                    final episode = podcast.episodes[index];

                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6.0), // Rounded corners for the image
                        child: CachedNetworkImage(placeholder: (context, url) => const SizedBox(width: 50, height: 50, child: Center(child: CircularProgressIndicator())),
                            errorWidget: (context, url, error) => const Icon(Icons.broken_image_outlined, size: 50),
                            imageUrl: episode.imageUrl ?? podcast.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover),
                      ),
                      title: Text(episode.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(episode.pubDate, style: TextStyle(color: Colors.grey.shade600)),
                            Text(episode.duration ?? "-")
                          ]),
                      onTap: () async {
                        setState(() {
                          _selectedEpisode = episode;
                          _loadMedia(context, episode);
                        });
                        //Navigator.pushNamed(context, '/player', arguments: episode);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _scrollBox(String text, double maxHeight) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          // Create a gradient that goes from opaque white at the top/middle
          // to transparent white at the very bottom edge.
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white, // Opaque part of the mask
              Colors.white, // Opaque part of the mask
              Colors.transparent, // Fades out at the bottom
            ],
            // Adjust stops to control where the fade starts.
            // Closer to 1.0 means the fade is shorter and only at the very bottom.
            // Lower values (e.g., 0.8, 0.9) start the fade higher up.
            stops: const [0.0, 0.9, 1.0], // Fade starts at 90% of the height
          ).createShader(bounds);
        },
        // This blend mode applies the shader's alpha channel (transparency)
        // to the child widget.
        blendMode: BlendMode.dstIn,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(0), // Add extra padding at bottom if needed
            child: Text(text),
          ),
        ),
      ),
    );
  }

  bool _isHandlerLoaded = false;

  Future<void> _loadMedia(BuildContext context, FeedEpisode episode) async {
    final audioHandler = context.read<AudioHandler>();

    if (_isHandlerLoaded && audioHandler.mediaItem.value?.id == episode.mediaUrl) {
      return;
    }

    final mediaItem = MediaItem(
        id: episode.mediaUrl,
        title: audioHandler.mediaItem.value?.title ?? "No title",
        duration: audioHandler.mediaItem.value?.duration,
        artUri: audioHandler.mediaItem.value?.artUri
    );

    await audioHandler.playMediaItem(mediaItem);

    if (mounted) {
      setState(() {
        _isHandlerLoaded = true;
      });
    }
  }
}