import 'dart:io'; // Provides File, Directory classes
import 'package:path_provider/path_provider.dart'; // Finds directories
import 'package:path/path.dart' as p; // For joining path components robustly
import 'package:uuid/uuid.dart';

String generateRandomFileName(String extension) {
  var uuid = Uuid();
  String randomUuid = uuid.v4();
  String fileName = '$randomUuid.$extension';

  return fileName;
}

Future<bool> deleteFileInDocumentsDirectory(String fileName) async {
  try {
    // 1. Get the application documents directory path
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;

    // 2. Construct the full file path using the path package for safety
    final String filePath = p.join(appDocPath, fileName);

    // 3. Create a File object
    final File fileToDelete = File(filePath);

    // 4. Check if the file exists before attempting to delete
    if (await fileToDelete.exists()) {
      // 5. Delete the file
      await fileToDelete.delete();
      return true; // Indicate success
    } else {
      return false; // Indicate file not found
    }
  } catch (e) {
    // 6. Handle potential errors (e.g., permissions, OS errors)
    return false; // Indicate failure due to error
  }
}
