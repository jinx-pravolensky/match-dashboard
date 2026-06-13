import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String ipAddress = '192.168.0.105';
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    return 'http://$ipAddress:3000/api';
  }

  /* 
  static const String vpsIpAddress = 'http://76.13.17.73:3000';
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    return '$vpsIpAddress/api';
  }
  */
}
