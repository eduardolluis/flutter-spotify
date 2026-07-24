import 'dart:io';

class ServerConstants {
  static const bool isPhysicalDevice = true;

  static String get serverURL {
    if (isPhysicalDevice) {
      return 'http://10.0.0.155:8000';
    }

    return Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://127.0.0.1:8000';
  }
}
