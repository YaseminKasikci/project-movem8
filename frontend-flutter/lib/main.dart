// 📁 lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routes/app_routes.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();

    // Initialise AppLinks
    _appLinks = AppLinks();

    // Gérer le lien initial (ex: si l’app est ouverte via un lien)
    _handleInitialLink();

    // Écouter les liens arrivant pendant que l’app est ouverte
    _linkSubscription = _appLinks.uriLinkStream.listen(_onUri, onError: (err) {
      debugPrint("❌ Erreur stream deep link: $err");
    });
  }

  /// Vérifie si un lien a lancé l'app
  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialAppLink();
      _onUri(uri);
    } catch (e) {
      debugPrint("❌ Erreur initial link: $e");
    }
  }

  /// Traite les liens entrants
  void _onUri(Uri? uri) {
    if (uri == null) return;
    debugPrint("🔗 Lien reçu: $uri");

    if (uri.scheme == 'movem8' && uri.host == 'reset-password') {
      final token = uri.queryParameters['token'] ?? '';
      debugPrint("🔐 Token reçu via lien : $token");
      navigatorKey.currentState?.pushNamed(AppRoutes.resetPassword, arguments: token);

    } else if (uri.scheme == 'movem8' && uri.host == 'two-factor') {
      final email = uri.queryParameters['email'] ?? '';
      debugPrint("📧 Email reçu via lien : $email");
      navigatorKey.currentState?.pushNamed(AppRoutes.twoFactor, arguments: email);
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'MoveM8',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 0.9),
          child: child!,
        );
      },
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.copyWith(
            bodyLarge: const TextStyle(fontSize: 20),
            titleLarge: const TextStyle(fontSize:27, fontWeight: FontWeight.bold,),
            labelLarge: const TextStyle(fontSize: 20),
          ),
        ),
        primaryTextTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
