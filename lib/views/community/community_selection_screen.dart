import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:move_m8/models/auth_model.dart';
import 'package:move_m8/models/community_model.dart';
import 'package:move_m8/routes/app_routes.dart';
import 'package:move_m8/services/community_service.dart';
import 'package:move_m8/services/user_service.dart';

class CommunitySelectionScreen extends StatefulWidget {
  final AuthModel user;
  final bool pickMode; // 👈 permet d’utiliser l’écran comme “picker”

  const CommunitySelectionScreen({
    Key? key,
    required this.user,
    this.pickMode = false,
  }) : super(key: key);

  @override
  State<CommunitySelectionScreen> createState() =>
      _CommunitySelectionScreenState();
}

class _CommunitySelectionScreenState extends State<CommunitySelectionScreen> {
  final _svc = CommunityService();

  bool _isAdmin = false;
  List<CommunityModel> _communities = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadUserRole();
    await _loadCommunities();
  }

  /// Charge le rôle d’abord depuis SharedPreferences, puis fallback API
  Future<void> _loadUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final role = (jsonDecode(userJson) as Map<String, dynamic>)['role'] as String?;
        if (role != null) {
          setState(() => _isAdmin = role == 'ADMIN');
          return;
        }
      }
      final me = await UserService().getMyProfile();
      setState(() => _isAdmin = me.role == "ADMIN");
    } catch (_) {
      setState(() => _isAdmin = false);
    }
  }

  Future<void> _loadCommunities() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final list = await _svc.fetchAll();
      setState(() => _communities = list);
    } on CommunityException catch (ce) {
      setState(() => _error = ce.message);
    } catch (_) {
      setState(() => _error = 'Erreur inattendue');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onCommunityTap(CommunityModel c) async {
    try {
      await _svc.joinCommunity(widget.user.userId, c.id);
      await _svc.chooseCommunity(widget.user.userId, c.id);

      if (!mounted) return;

      if (widget.pickMode) {
        Navigator.pop(context, c);
      } else {
        Navigator.pushNamed(
          context,
          AppRoutes.communityHome,
          arguments: c,
        );
      }
    } on CommunityException catch (ce) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ce.message)));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur inattendue')),
      );
    }
  }

  // ---------- Admin CRUD ----------
  void _showCreateCommunitySheet() {
    String name = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Ajouter une communauté",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: "Nom"),
              onChanged: (v) => name = v,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (name.trim().isEmpty) return;
                try {
                  await _svc.create(name.trim());
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  _loadCommunities();
                } catch (_) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Erreur de création")),
                  );
                }
              },
              child: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCommunitySheet(CommunityModel c) {
    final controller = TextEditingController(text: c.communityName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("Modifier la communauté",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Nom"),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;
              try {
                await _svc.update(c.id, newName);
                if (!mounted) return;
                Navigator.pop(ctx);
                _loadCommunities();
              } catch (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Erreur de modification")),
                );
              }
            },
            child: const Text("Modifier"),
          ),
        ]),
      ),
    );
  }

  void _confirmDeleteCommunity(CommunityModel c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: Text("Supprimer « ${c.communityName} » ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _svc.delete(c.id);
                if (!mounted) return;
                setState(() => _communities.removeWhere((x) => x.id == c.id));
              } catch (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Erreur lors de la suppression")),
                );
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CurvedHeader(
                    title: 'Choice your community',
                    leading: widget.pickMode
                        ? const BackButton(color: Colors.white)
                        : _menuPopup(),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'COMMUNITY',
                      style: TextStyle(
                        color: const Color(0xFF5CC7B4),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _error.isNotEmpty
                          ? Center(
                              child: Text(
                                _error,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              itemCount: _communities.length,
                              itemBuilder: (_, i) {
                                final c = _communities[i];
                                return CommunityCard(
                                  title: c.communityName,
                                  icon: _iconFor(c.communityName),
                                  onTap: () => _onCommunityTap(c),
                                  onEdit: _isAdmin ? () => _showEditCommunitySheet(c) : null,
                                  onDelete: _isAdmin ? () => _confirmDeleteCommunity(c) : null,
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: _isAdmin
          ? Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 24),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton(
                  heroTag: 'addCommunityFAB',
                  backgroundColor: const Color(0xFF5CC7B4),
                  onPressed: _showCreateCommunitySheet,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _menuPopup() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.white),
      onSelected: (value) async {
        switch (value) {
          case 'profile':
            Navigator.pushNamed(context, AppRoutes.profile);
            break;
          case 'logout':
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            widget.user.email,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'profile',
          child: Text('profile'),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Text('Déconnexion'),
        ),
      ],
    );
  }

  IconData _iconFor(String name) {
    final key = name.toLowerCase();
    if (key.contains('pregnan')) return Icons.pregnant_woman;
    if (key.contains('senior')) return Icons.elderly;
    if (key.contains('kid') || key.contains('child')) return Icons.tag_faces;
    if (key.contains('pet') || key.contains('animal')) return Icons.pets;
    if (key.contains('every')) return Icons.groups_2_outlined;
    return Icons.group_outlined;
  }
}

/// Header courbé + titre + leading custom (menu ou back)
class CurvedHeader extends StatelessWidget {
  final String title;
  final Widget leading;

  const CurvedHeader({
    super.key,
    required this.title,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        color: const Color(0xFF5CC7B4),
        padding: const EdgeInsets.only(top: 18, left: 8, right: 16, bottom: 18),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                leading,
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final r = 36.0;
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width - r, size.height);
    path.quadraticBezierTo(size.width, size.height, size.width, size.height - r);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class CommunityCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CommunityCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const mint = Color(0xFFE6FBF7);
    const accent = Color(0xFF5CC7B4);

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: mint,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 72, 18),
            child: Row(
              children: [
                Icon(icon, size: 48, color: Colors.black87),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 18,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 48,
              height: 30,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
            ),
          ),
        ),
        if (onEdit != null)
          Positioned(
            top: 6,
            right: 64,
            child: IconButton(
              tooltip: 'Modifier',
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
            ),
          ),
        if (onDelete != null)
          Positioned(
            top: 6,
            right: 30,
            child: IconButton(
              tooltip: 'Supprimer',
              icon: const Icon(Icons.close, color: Colors.red, size: 20),
              onPressed: onDelete,
            ),
          ),
      ],
    );
  }
}
