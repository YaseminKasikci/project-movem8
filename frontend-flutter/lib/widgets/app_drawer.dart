import 'package:flutter/material.dart';
import 'package:move_m8/routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  final String email;
  final String? avatarUrl; // photo de profil éventuelle

  const AppDrawer({
    Key? key,
    required this.email,
    this.avatarUrl,
  }) : super(key: key);

  static const Color moveM8 = Color(0xFF5CC7B4);
  static const Color danger = Colors.red;

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
                    backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                        ? NetworkImage(avatarUrl!)
                        : null,
                    child: (avatarUrl == null || avatarUrl!.isEmpty)
                        ? const Icon(Icons.person,
                            size: 40, color: moveM8)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    email,
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
              title: const Text(
                'Déconnexion',
                style: TextStyle(color: danger),
              ),
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
