import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:podsink/services/podcast_service.dart';
import 'package:podsink/utils/widget_helper.dart';
import 'package:podsink/widgets/busy_button.dart';
import 'package:provider/provider.dart';

class AddPodcastScreen extends StatefulWidget {
  const AddPodcastScreen({super.key});

  @override
  _AddPodcastScreenState createState() => _AddPodcastScreenState();
}

class _AddPodcastScreenState extends State<AddPodcastScreen> {
  final TextEditingController _feedUrlController = TextEditingController();
  bool _isBusy = false;

  void _addPodcast() async {
    if (!mounted) return;
    try {
      _isBusy = true;
      if (_feedUrlController.text.isEmpty || !_feedUrlController.text.startsWith('http')) {
        _showDialog(context);
        return;
      }
      final service = Provider.of<PodcastService>(context, listen: false);
      final podcast = service.savePodcastsWithEpisodes(_feedUrlController.text);
      if (podcast != null) {
        Navigator.pop(context, podcast);
      }
    } catch (e) {
      showSnackbar(context, '$e');
    } finally {
      _isBusy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Podcast')),
      body: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(children: [
              const Align(alignment: Alignment.centerLeft, child:  Text("Feed URL", style: TextStyle(fontSize: 20))),
              Divider(),
              TextField(
                  maxLines: 15,
                  keyboardType: TextInputType.multiline,
                  controller: _feedUrlController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),

              ),
              SizedBox(height: 10),
              Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: _pasteFromClipboard, child: Text("Paste from clipboard"))),
              SizedBox(height: 20),
            ]),
            BusyButton(isBusy: _isBusy, label: "Add feed URL", onPressed: _addPodcast),
          ],
        ),
      ),
    );
  }

  // Function to handle the paste action
  Future<void> _pasteFromClipboard() async {
    // 1. Get the data from the clipboard.
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);

    // 2. Check if there's text data.
    if (data != null && data.text != null) {
      final String clipboardText = data.text!;
      _feedUrlController.text = clipboardText.trim();
    }
  }
}

Future<void> _showDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: const Text("Invalid values"),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
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
