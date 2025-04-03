import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

void showUpdateDialog(BuildContext context, String storeUrl) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissal by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Update Available"),
        content: Text("A new version of the app is available. Please update for the latest features and improvements."),
        actions: <Widget>[
          TextButton(
            child: Text("Later"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("Update Now"),
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog first
              final Uri uri = Uri.parse(storeUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                // Handle error: Cannot launch URL
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open the app store.')));
              }
            },
          ),
        ],
      );
    },
  );
}

// --- Usage ---
Future<void> checkMyApiAndUpdate(BuildContext context) async {
  /*
  // 1. Get current version (using package_info_plus)
  String currentVersion = await getCurrentAppVersion();

  // 2. Fetch latest version from your API (using http/dio)
  // Replace with your actual API call
  Map<String, dynamic>? versionData = await fetchLatestVersionFromApi();

  if (versionData != null) {
    String latestVersion =
        Platform.isAndroid
            ? versionData['latestAndroidVersion']
            : versionData['latestIosVersion'];
    String storeUrl =
        Platform.isAndroid
            ? versionData['androidStoreUrl'] // e.g., "market://details?id=your.package.name" or https URL
            : versionData['iosStoreUrl']; // e.g., "itms-apps://itunes.apple.com/app/idYOUR_APP_ID" or https URL

    if (isUpdateAvailable(currentVersion, latestVersion)) {
      showUpdateDialog(context, storeUrl);
    }
  }
   */
}
