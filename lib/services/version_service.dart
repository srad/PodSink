import 'package:flutter/material.dart';
//import 'package:in_app_update/in_app_update.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:version/version.dart';

void checkVersion(BuildContext context) async {
  final newVersion = NewVersionPlus(
    // Provide specific IDs if needed, otherwise it tries to look them up
    // androidId: "your.package.name",
    // iOSId: "your.bundle.id",
    // iOSAppStoreCountry: "US", // Optional
  );

  final status = await newVersion.getVersionStatus();
  if (status != null && status.canUpdate) {
    newVersion.showUpdateDialog(
      context: context,
      versionStatus: status,
      dialogTitle: 'Update Available',
      dialogText:
          'A new version (${status.storeVersion}) is available. Update now?',
      updateButtonText: 'Update',
      dismissButtonText: 'Later',
    );
  }
}

bool isUpdateAvailable(String currentVersionStr, String latestVersionStr) {
  try {
    final currentVersion = Version.parse(currentVersionStr);
    final latestVersion = Version.parse(latestVersionStr);
    return latestVersion > currentVersion;
  } catch (e) {
    print("Error comparing versions: $e");
    return false; // Handle parsing errors
  }
}

Future<void> checkForAndroidUpdate() async {
  // try {
  //   AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
  //   if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
  //     // Update available - decide on flexible or immediate
  //     if (updateInfo.immediateUpdateAllowed) {
  //       await InAppUpdate.performImmediateUpdate();
  //     } else if (updateInfo.flexibleUpdateAllowed) {
  //       await InAppUpdate.startFlexibleUpdate();
  //       // Optional: Complete the flexible update when ready
  //       // await InAppUpdate.completeFlexibleUpdate();
  //     }
  //   }
  // } catch (e) {
  //   print("Error checking for update: $e");
  //   // Handle error (e.g., network issue)
  // }
}
