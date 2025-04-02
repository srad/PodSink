import 'package:flutter/material.dart';
import 'package:podsink/models/podcast.dart';
import 'package:podsink/services/db_service.dart';

class AddPodcastScreen extends StatefulWidget {
  const AddPodcastScreen({super.key});

  @override
  _AddPodcastScreenState createState() => _AddPodcastScreenState();
}

class _AddPodcastScreenState extends State<AddPodcastScreen> {
  //final TextEditingController _titleController = TextEditingController();
  final TextEditingController _feedUrlController = TextEditingController();

  void _addPodcast() async {
    if (_feedUrlController.text.isEmpty && !_feedUrlController.text.contains('http')) {
      _dialogBuilder(context);
      return;
    }
    final dbService = DBService();
    final podcast = Podcast(
      id: null, // Auto-increment
      title: '', //_titleController.text,
      feedUrl: _feedUrlController.text,
    );
    final insertedPodcast = await dbService.addPodcast(podcast);
    Navigator.pop(context, insertedPodcast); // Go back to previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Podcast')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /*
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
             */
            SizedBox(height: 20),
            TextField(
              controller: _feedUrlController,
              decoration: InputDecoration(labelText: 'Feed URL'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _addPodcast, child: Text('Add Podcast')),
          ],
        ),
      ),
    );
  }
}

Future<void> _dialogBuilder(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: const Text("Invalid values"),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
