import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';

final updateServiceProvider = Provider((ref) => UpdateService());

class UpdateService {
  /// Check if an update is available via Google Play
  Future<bool> checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      
      // Developer override for testing the UI locally
      // Set to false before releasing to production!
      const bool forceTestMode = false; 
      
      if (kDebugMode && forceTestMode) {
        debugPrint('⚠️ OVERRIDE: Forcing update required screen for testing');
        return true; 
      }

      return info.updateAvailability == UpdateAvailability.updateAvailable;
    } catch (e) {
      debugPrint('⚠️ InAppUpdate check failed: $e');
      
      // Developer override for testing the UI locally
      const bool forceTestMode = false; 
      if (kDebugMode && forceTestMode) {
        debugPrint('⚠️ OVERRIDE: Forcing update required screen for testing despite exception');
        return true; 
      }
      
      return false;
    }
  }

  /// Trigger the native Google Play update flow
  Future<void> performUpdate() async {
    try {
      await InAppUpdate.performImmediateUpdate();
    } catch (e) {
      debugPrint('⚠️ InAppUpdate perform failed: $e');
      // If it fails (e.g. because we are in debug mode testing), 
      // we could fallback to url_launcher to open the Play Store link here.
    }
  }
}
