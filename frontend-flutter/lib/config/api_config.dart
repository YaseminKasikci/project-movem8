// 📁 lib/config/api_config.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  /// Host par défaut : le nom Bonjour/mDNS de ton Mac
  /// -> override possible via: flutter run --dart-define=API_HOST=MacBook-Air-de-Moi.local
  static const String host = String.fromEnvironment(
    'API_HOST',
    defaultValue: 'MacBook-Air-de-Moi.local',
  );

  /// Sélection du host en fonction de la plateforme
  static String get _host {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2'; // émulateur Android
    if (Platform.isIOS) return host;           // iOS simu + device (mDNS)
    return 'localhost';
  }

  static const int _port = 8080;

  /// Base de l’API: http://host:port/api
  static Uri get base => Uri(
        scheme: 'http',
        host: _host,
        port: _port,
        path: 'api',
      );

  /// Helpers pour construire des Uris propres
  static Uri path(List<String> segments) => base.replace(
        pathSegments: [...base.pathSegments, ...segments],
      );

  // Endpoints
  static Uri get auth        => path(['auth']);
  static Uri get users       => path(['users']);
  static Uri get communities => path(['communities']);
  static Uri get categories  => path(['categories']);
  static Uri get sports      => path(['sports']);
  static Uri get activities  => path(['activities']);

  /// Utilitaire: corrige un URL d’image "localhost" -> host courant (10.0.2.2 / .local)
  static String fixImageHost(String url) {
    try {
      final u = Uri.parse(url);
      // Hosts à réécrire
      final hostsToRewrite = {
        'localhost',
        '127.0.0.1',
        '10.0.2.2',
        if (u.host.startsWith('192.168.')) u.host, // ex. anciens liens LAN
      };
      if (hostsToRewrite.contains(u.host)) {
        return u.replace(host: _host, port: _port).toString();
      }
      return url;
    } catch (_) {
      return url;
    }
  }
}
