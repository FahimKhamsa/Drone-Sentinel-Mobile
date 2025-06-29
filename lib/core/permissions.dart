// lib/core/permissions.dart

import 'package:permission_handler/permission_handler.dart';

/// Handles application permissions.
class AppPermissions {
  /// Requests microphone permission from the user.
  /// Returns `true` if permission is granted, `false` otherwise.
  static Future<bool> requestMicrophonePermission() async {
    // Check current status of microphone permission
    var status = await Permission.microphone.status;

    // If permission is not granted, request it
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    // Return whether the permission is granted
    return status.isGranted;
  }
}
