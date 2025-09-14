// lib/utils/url_utils.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

String fixHost(String? url) {
  if (url == null || url.isEmpty) return '';
  if (kIsWeb) return url;

  final loopback = RegExp(r'^https?://(localhost|127\.0\.0\.1)');
  if (Platform.isAndroid && loopback.hasMatch(url)) {
    return url.replaceFirst(loopback, 'http://10.0.2.2');
  }
  // iOS/macOS: garder localhost/127.0.0.1 pour le simulateur
  return url;
}
