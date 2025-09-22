// lib/widgets/app_drawer.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:move_m8/config/api_config.dart';
import 'package:move_m8/routes/app_routes.dart';
import 'package:move_m8/services/user_service.dart';

class AppDrawer extends StatefulWidget {
  final String email;
  final String? avatarUrl; // optionnel : si null, on va la chercher

  const AppDrawer({
    Key? key,
    required this.email,
    this.avatarUrl,
  }) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  static const Color moveM8 = Color(0xFF5CC7B4);
  static const Color danger = Colors.red;

  String _fixedUrl = '';
  bool _loadingAvatar = false;

  @override
  void initState() {
    super.initState();
    // 1) utilise l’URL passée si dispo
    if ((widget.avatarUrl ?? '').isNotEmpty) {
      _fixedUrl = ApiConfig.fixImageHost(widget.avatarUrl!.trim());
    } else {
      // 2) sinon, va chercher la photo du user
      _fetchAvatar();
    }
  }

  Future<void> _fetchAvatar() async {
    setState(() => _loadingAvatar = true);
    try {
      final me = await UserService().getMyProfile();
      final raw = (me.pictureProfile ?? '').trim();
      if (!mounted) return;
      setState(() {
        _fixedUrl = raw.isEmpty ? '' : ApiConfig.fixImageHost(raw);
      });
      debugPrint('AppDrawer fetched avatar raw="$raw" fixed="$_fixedUrl"');
    } catch (e) {
      debugPrint('AppDrawer avatar fetch error: $e');
    } finally {
      if (mounted) setState(() => _loadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ----- HEADER : avatar au-dessus + email dessous -----
            DrawerHeader(
              decoration: const BoxDecoration(color: moveM8),
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: _fixedUrl.isEmpty
                            ? (_loadingAvatar
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.person,
                                    size: 40, color: moveM8))
                            : Image.network(
                                _fixedUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (c, child, prog) {
                                  if (prog == null) return child;
                                  return const Center(
                                      child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ));
                                },
                                errorBuilder: (c, err, st) {
                                  debugPrint(
                                      '❌ Drawer avatar load error for "$_fixedUrl": $err');
                                  return const Icon(Icons.person,
                                      size: 40, color: moveM8);
                                },
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ----- ITEMS -----
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            ),
            const Divider(height: 8),
            ListTile(
              leading: const Icon(Icons.gavel),
              title: const Text('Mentions légales'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.legalNotices),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Politique de confidentialité'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.privacyPolicy),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Conditions Générales d’Utilisation'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.terms),
            ),

            const Spacer(),

            // ----- DÉCONNEXION -----
            ListTile(
              leading: const Icon(Icons.logout, color: danger),
              title: const Text('Déconnexion',
                  style: TextStyle(color: danger)),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
