// 📁 lib/widgets/activity_card_mock.dart (design aligné à la maquette « Everyone → Liste »)
// Changements clés:
// - Niveau: police plus petite
// - Photo activité: plus compacte (moins large & moins haute)
// - Ajout du Titre (title prioritaire, fallback sportName)
// - Ajout de la Description (2 lignes max, gris)
// - Espacements et rayons harmonisés

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:move_m8/config/api_config.dart';
import 'package:move_m8/widgets/favorite_button.dart';
import '../models/activity_model.dart' as models;

class ActivityCardMock extends StatelessWidget {
  const ActivityCardMock({super.key, required this.activity, this.onTap});

  final models.ActivityCard activity;
  final VoidCallback? onTap;

  // ===== Helpers =====
  Color get _levelColor => _hexToColor(activity.level.color);

  String get _dateLine =>
      DateFormat('EEE. d MMM.', 'fr_FR').format(activity.dateHour);
  String get _timeLine =>
      DateFormat("H'h'mm", 'fr_FR').format(activity.dateHour);

  String get _creatorLine {
    final first = (activity.creatorFirstName ?? '').trim();
    final age = activity.creatorAge;
    if (first.isEmpty && age == null) return '';
    if (first.isNotEmpty && age != null) return '$first, $age';
    return first.isNotEmpty ? first : '$age';
  }

  String get _titleText {
    final t = (activity.title ?? '').trim();
    if (t.isNotEmpty) return t;
    return (activity.sportName ?? '').trim();
  }

  String? get _descriptionText {
    final d = (activity.description ?? '').trim();
    return d.isEmpty ? null : d;
  }

  @override
  Widget build(BuildContext context) {
    final color = _levelColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Material(
        color: Colors.white,
        elevation: 4,
        shadowColor: const Color(0x1A000000),
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header bandeau =====
              SizedBox(
                height: 120,
                child: LayoutBuilder(
                  builder: (ctx, cons) {
                    final imgW = cons.maxWidth * 0.50; // moins large qu'avant
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Fond dégradé selon le niveau
                        ClipPath(
                          clipper: _HeaderClipper(),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  color.withOpacity(.95),
                                  color.withOpacity(.70),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Bloc textes (créateur, niveau, sport)
                        Positioned(
                          left: 28,
                          top: 16,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: cons.maxWidth * 0.48,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_creatorLine.isNotEmpty) ...[
                                  Text(
                                    _creatorLine,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                // Niveau (plus petit)
                                Text(
                                  activity.level.label.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  (activity.sportName ?? activity.title)
                                      .toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(.12),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Photo activité (droite) — plus petite
                        Positioned(
                          right: 22,
                          top: 18,
                          child: Container(
                            width: imgW,
                            height: 108,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                              image:
                                  (activity.photo != null &&
                                      activity.photo!.isNotEmpty)
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        ApiConfig.fixImageHost(activity.photo!),
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: const Color(0xFFEFEFEF),
                            ),
                            child:
                                (activity.photo == null ||
                                    activity.photo!.isEmpty)
                                ? const Center(
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.black38,
                                    ),
                                  )
                                : null,
                          ),
                        ),

                        // Avatar créateur (chevauche)
                        Positioned(
                          left: 24,
                          bottom: -26,
                          child: _CreatorAvatar(
                            photoUrl: activity.creatorPhotoUrl,
                            size: 72,
                          ),
                        ),

                        // Bouton favori
                        // Bouton favori (toggle rouge au clic, sans fond blanc)
                        Positioned(
                          right: 26,
                          bottom: -24,
                          child: const FavoriteButton(),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),

              // ===== Titre =====
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _titleText.isEmpty
                        ? (activity.sportName ?? '')
                        : _titleText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ===== Description =====
              if (_descriptionText != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Text(
                    _descriptionText!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B6B6B),
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // ===== Infos (date, heure, lieu, participants) =====
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          _dateLine,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.access_time),
                        const SizedBox(width: 6),
                        Text(
                          _timeLine,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
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

/// Petit avatar avec bord blanc & fallback
class _CreatorAvatar extends StatelessWidget {
  final String? photoUrl;
  final double size;
  const _CreatorAvatar({this.photoUrl, this.size = 72});

  @override
  Widget build(BuildContext context) {
    final img = (photoUrl != null && photoUrl!.isNotEmpty)
        ? NetworkImage(ApiConfig.fixImageHost(photoUrl!))
        : null;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundImage: img,
        backgroundColor: const Color(0xFFE9E9E9),
        child: img == null
            ? const Icon(Icons.person, color: Colors.black45, size: 32)
            : null,
      ),
    );
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
      ..quadraticBezierTo(
        size.width - 8,
        size.height - 8,
        size.width - scoop,
        size.height,
      )
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
