// 📁 lib/widgets/activity_card_mock.dart
// Version corrigée pour utiliser le nouveau modèle `models.ActivityCard`
// et l’enum Level (avec .label et .color hex).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/activity_model.dart' as models;

class ActivityCardMock extends StatelessWidget {
  const ActivityCardMock({super.key, required this.activity, this.onTap});

  final models.ActivityCard activity;
  final VoidCallback? onTap;

  Color get _levelColor => _hexToColor(activity.level.color);

  String get _dateLine {
    // Ex: "Dim. 20 nov."
    final d = DateFormat('EEE. d MMM.', 'fr_FR');
    return d.format(activity.dateHour);
  }

  String get _timeLine {
    // Ex: "7h30"
    final t = DateFormat("H'h'mm", 'fr_FR');
    return t.format(activity.dateHour);
  }

  @override
  Widget build(BuildContext context) {
    final color = _levelColor;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 14, offset: Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bandeau haut avec forme + image + badge niveau
            SizedBox(
              height: 190,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Bandeau (forme arrondie + dégradé niveau)
                  ClipPath(
                    clipper: _HeaderClipper(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [color.withOpacity(.95), color.withOpacity(.75)],
                        ),
                      ),
                    ),
                  ),

                  // Texte gauche : label niveau + éventuellement sport
                  Positioned(
                    left: 32,
                    top: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.level.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (activity.sportName ?? activity.title).toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            shadows: [Shadow(color: Colors.black.withOpacity(.1), blurRadius: 4)],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Photo d'activité (droite)
                  Positioned(
                    right: 24,
                    top: 22,
                    child: Container(
                      width: 360,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 6))],
                        image: (activity.photo != null && activity.photo!.isNotEmpty)
                            ? DecorationImage(image: NetworkImage(activity.photo!), fit: BoxFit.cover)
                            : null,
                        color: const Color(0xFFEFEFEF),
                      ),
                      child: (activity.photo == null || activity.photo!.isEmpty)
                          ? const Center(child: Icon(Icons.image, color: Colors.black38))
                          : null,
                    ),
                  ),

                  // Icône sport en avatar (si dispo) — remplace l'avatar créateur
                 

                  // Coeur favori (bord rouge)
                  Positioned(
                    right: 26,
                    bottom: -24,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8)],
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border, size: 28),
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 46),

            // Titre (= sportName ou title)
            Center(
              child: Text(
                activity.sportName ?? activity.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 0.3),
              ),
            ),
            const SizedBox(height: 10),

            // Date & lieu & participants/time
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        _dateLine,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time),
                      const SizedBox(width: 6),
                      Text(_timeLine, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          activity.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.groups_2_outlined),
                      const SizedBox(width: 6),
                      Text('${activity.numberOfParticipant}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- utils ---
  Color _hexToColor(String hex) {
    var cleaned = hex.replaceFirst('#', '');
    if (cleaned.length == 6) cleaned = 'FF$cleaned';
    return Color(int.parse(cleaned, radix: 16));
  }
}

// Découpe arrondie en bas à droite du bandeau
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const br = 28.0; // rayon global
    const scoop = 70.0; // creux en bas à droite

    final p = Path()
      ..moveTo(br, 0)
      ..lineTo(size.width - br, 0)
      ..quadraticBezierTo(size.width, 0, size.width, br)
      ..lineTo(size.width, size.height - scoop)
      ..quadraticBezierTo(size.width - 8, size.height - 8, size.width - scoop, size.height)
      ..lineTo(br, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - br)
      ..lineTo(0, br)
      ..quadraticBezierTo(0, 0, br, 0)
      ..close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
