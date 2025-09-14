// /// Point d’entrée de ton API back
// const String apiBaseUrl = 'http://192.168.1.31:8080/';

// /// Tous les endpoints d’authentification partent de /api/auth
// final String authBase = '${apiBaseUrl}api/auth/';

// /// Tous les endpoints de community /api/ communities
// final String communityBase = '${apiBaseUrl}api/communities/';
// final String categoryBase = '${apiBaseUrl}api/categories';
// final String sportBase = '${apiBaseUrl}api/sports';
// final String activityBase = '${apiBaseUrl}api/activities';



// /// Tous les endpoints de community /api/ communities
// final String userBase = '${apiBaseUrl}api/users';


// 📁 lib/config/api.dart
// lib/config/api_config.dart

// import 'dart:io';

// class ApiConfig {
//   static const String _lanIp = '192.168.1.198';

//   static String get baseUrl {
//     if (Platform.isAndroid) {
//       // Émulateur Android
//       return 'http://10.0.2.2:8080/';
//     } else if (Platform.isIOS) {
//       // iPhone physique : IP LAN (pas localhost)
//       return 'http://$_lanIp:8080/';
//     } else {
//       // iOS Simulator / macOS dev
//       return 'http://localhost:8080/';
//     }
//   }

//   static String get authBase     => '${baseUrl}api/auth/';
//   static String get communityBase=> '${baseUrl}api/communities/';
//   static String get categoryBase => '${baseUrl}api/categories/';
//   static String get sportBase    => '${baseUrl}api/sports';    
//   static String get activityBase => '${baseUrl}api/activities/';
//   static String get userBase     => '${baseUrl}api/users';
// }

// lib/config/api_config.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // ↳ Mets ici l’IP de ta machine quand tu testes sur iPhone/Android physiques
  static const String lanIp = '192.168.1.198';

  /// Hôte en fonction de la plateforme
  static String get _host {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2'; // émulateur Android
    if (Platform.isIOS) {
      // iOS Simulator: 'localhost' marche aussi.
      // iPhone physique: remplace par ton IP LAN (idem ci-dessus).
      // -> Choix simple : utilise l’IP LAN pour iOS (simu + device).
      return lanIp;
    }
    return 'localhost';
  }

  static const int _port = 8080;

  /// Base de l’API: http://host:port/api
  static Uri get base => Uri(scheme: 'http', host: _host, port: _port, path: 'api');

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

  /// Utilitaire: corrige un URL d’image "localhost" -> host courant (10.0.2.2 / LAN)
  static String fixImageHost(String url) {
  try {
    final u = Uri.parse(url);
    // Liste des hosts à réécrire (localhost + réseaux privés courants)
    final hostsToRewrite = {
      'localhost',
      '127.0.0.1',
      '10.0.2.2',
      // tout 192.168.x.x
      if (u.host.startsWith('192.168.')) u.host,
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

