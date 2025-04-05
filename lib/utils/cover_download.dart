import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:podsink/utils/file_helper.dart';
import 'package:uuid/uuid.dart';

class CoverDownloader {
  // This function downloads the image, resizes it, and saves it locally with a given name
  static Future<File> downloadAndResizePodcastCoverImage(String imageUrl, String coverName) async {
    // Get the directory to save the image
    final directory = await getApplicationDocumentsDirectory();
    final coverDirectory = Directory('${directory.path}/covers');

    // Create the directory if it doesn't exist
    if (!await coverDirectory.exists()) {
      await coverDirectory.create(recursive: true);
    }

    // Define the file path with the given cover name
    final filePath = '${coverDirectory.path}/$coverName';

    // Fetch the image from the URL
    final response = await http.get(Uri.parse(imageUrl));

    // Decode the image into an img.Image object
    img.Image? image = img.decodeImage(response.bodyBytes);

    if (image == null) {
      throw Exception("Failed to decode image");
    }

    // Resize the image to 128x128
    img.Image resizedImage = img.copyResize(image, width: 128, height: 128, maintainAspect: true);

    // Save the resized image to the local file
    final file = File(filePath)..writeAsBytesSync(img.encodeJpg(resizedImage));

    return file;
  }

  Future<bool> deleteCover(String filename) async {
    final filePath = 'covers/$filename';
    return await deleteFileInDocumentsDirectory(filePath);
  }
}
