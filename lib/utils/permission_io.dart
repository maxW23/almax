import 'package:lklk/core/utils/logger.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermission() async {
  debugAppLogger.debug('requestPermission...');
  try {
    final microphoneStatus = await Permission.microphone.request();
    if (microphoneStatus != PermissionStatus.granted) {
      debugAppLogger.debug('Error: Microphone permission not granted!!!');
      return false;
    }
  } on Exception catch (error) {
    debugAppLogger
        .debug('[ERROR], request microphone permission exception, $error');
  }

  try {
    final cameraStatus = await Permission.camera.request();
    if (cameraStatus != PermissionStatus.granted) {
      debugAppLogger.debug('Error: Camera permission not granted!!!');
      return false;
    }
  } on Exception catch (error) {
    debugAppLogger
        .debug('[ERROR], request camera permission exception, $error');
  }

  return true;
}
