import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:move_m8/enums/level.dart';
import 'package:move_m8/utils/url_utils.dart';

import '../../models/activity_model.dart' as models;

class ActivityDetailScreen extends StatefulWidget {
  final models.ActivityDetail activity;
  const ActivityDetailScreen({super.key, required this.activity});

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  int _tabIndex = 0;
  final Set<String> _levels = {"Beginner", "Intermediate", "Discovery", "Expert"};
  Level? _selectedLevel;



  String get _prettyDate => DateFormat('EEEE d MMMM', 'fr_FR').format(widget.activity.dateHour);
  String get _prettyTime => DateFormat('HH:mm').format(widget.activity.dateHour);

  Color _hexToColor(String hex) {
    var cleaned = hex.replaceFirst('#', '');
    if (cleaned.length == 6) cleaned = 'FF$cleaned';
    return Color(int.parse(cleaned, radix: 16));
  }


  @override
  Widget build(BuildContext context) {
    final a = widget.activity;
    final Color accent = _hexToColor(a.level.color);

    final creatorUrl = fixHost(a.creatorPhotoUrl);
    final headerUrl = fixHost(a.photo);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              _HeaderImage(url: headerUrl),
              // Bouton retour discret en haut à gauche
              Positioned(
                top: 16,
                left: 16,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white70,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              // Carte créateur
              Positioned(
                left: 0,
                right: 0,
                bottom: -1,
                child: _RoundedTopCard(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: creatorUrl.isNotEmpty
                              ? Image.network(
                                  creatorUrl,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Center(child: Icon(Icons.person)),
                                  ),
                                )
                              : const SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Center(child: Icon(Icons.person)),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${a.creatorFirstName ?? ''} ${a.creatorLastName ?? ''}'.trim(),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 18),
                                  const SizedBox(width: 4),
                                  Text((a.note ?? 0.0).toStringAsFixed(1)),
                                ],
                              )
                            ],
                          ),
                        ),
                        _LevelPill(label: a.level.label, glowColor: accent),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              (a.sportName?.isNotEmpty ?? false) ? a.sportName! : a.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _InfoTile(
                  leading: Icons.event,
                  textLeft: _prettyDate,
                  accent: accent,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 18, color: accent),
                      const SizedBox(width: 6),
                      Text(_prettyTime),
                    ],
                  ),
                ),
                _InfoTile(
                  leading: Icons.place_outlined,
                  textLeft: a.location.isNotEmpty ? a.location : 'Adresse indisponible',
                  accent: accent,
                ),
                _InfoTile(
                  leading: Icons.euro,
                  textLeft: a.price == 0 ? 'Gratuit' : '${a.price.toStringAsFixed(0)}€',
                  accent: accent,
                ),
                _ParticipantsTile(
                  countText: '${a.numberOfParticipant} participants',
                  avatars: creatorUrl,
                  accent: accent,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('More info',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 8),
                _Tabs(index: _tabIndex, onChanged: (i) => setState(() => _tabIndex = i), accent: accent),
              ],
            ),
          ),

          const SizedBox(height: 10),

        Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: _RoundedCard(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: _tabIndex == 0
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👉 titre de l’activité
                Text(
                  a.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // 👉 description
                Text(
                  a.description.isNotEmpty
                      ? a.description
                      : 'Aucune description fournie.',
                  textAlign: TextAlign.justify,
                ),
              ],
            )
          : const Text(
              'Matériel: chaussures adaptées, bouteille d’eau, serviette… (à compléter).',
              textAlign: TextAlign.justify,
            ),
    ),
  ),
),

          const SizedBox(height: 18),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Do you want to participate ? What is your level on this sport ?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),

          // Chips colorés
      Padding(
  padding: const EdgeInsets.symmetric(horizontal: 8),
  child: Wrap(
    spacing: 8,
    children: Level.values.map((level) {
      final selected = _selectedLevel == level;
      final color = _hexToColor(level.color);
      return FilterChip(
        label: Text(level.label),
        selected: selected,
        backgroundColor: color.withOpacity(0.2),
        selectedColor: color,
        labelStyle: TextStyle(
          color: selected ? Colors.white : color,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (v) => setState(() {
          _selectedLevel = v ? level : null; // exclusif
        }),
      );
    }).toList(),
  ),
),


          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: SizedBox(
                width: 200,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: accent, width: 1.5),
                    foregroundColor: accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {},
                  child: const Text('Participate'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// ---------------- Widgets privés ----------------

class _HeaderImage extends StatelessWidget {
  final String? url;
  const _HeaderImage({this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: (url != null && url!.isNotEmpty)
            ? Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
            : _placeholder(),
      ),
    );
  }

  static Widget _placeholder() => Container(
        color: Colors.black12,
        child: const Center(child: Icon(Icons.image, color: Colors.white70, size: 48)),
      );
}

class _RoundedTopCard extends StatelessWidget {
  final Widget child;
  const _RoundedTopCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: child,
    );
  }
}

class _RoundedCard extends StatelessWidget {
  final Widget child;
  const _RoundedCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }
}

class _LevelPill extends StatelessWidget {
  final String label;
  final Color glowColor;
  const _LevelPill({required this.label, required this.glowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: glowColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: glowColor.withOpacity(0.45), blurRadius: 20, spreadRadius: 1),
        ],
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData leading;
  final String textLeft;
  final Widget? trailing;
  final Color accent;
  const _InfoTile({required this.leading, required this.textLeft, this.trailing, required this.accent});

  @override
  Widget build(BuildContext context) {
    return _RoundedCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(leading, size: 20, color: accent),
            const SizedBox(width: 10),
            Expanded(child: Text(textLeft)),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    ).paddingOnly(bottom: 10);
  }
}

class _ParticipantsTile extends StatelessWidget {
  final String countText;
  final String? avatars;
  final Color accent;
  const _ParticipantsTile({required this.countText, this.avatars, required this.accent});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    if (avatars != null && avatars!.isNotEmpty) {
      items.add(
        ClipOval(
          child: Image.network(
            avatars!,
            width: 28,
            height: 28,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => CircleAvatar(
              radius: 14,
              backgroundColor: accent.withOpacity(0.15),
              child: Icon(Icons.person, size: 16, color: accent),
            ),
          ),
        ),
      );
    }

    while (items.length < 4) {
      items.add(
        CircleAvatar(
          radius: 14,
          backgroundColor: accent.withOpacity(0.15),
          child: Icon(Icons.person, size: 16, color: accent),
        ),
      );
    }

    return _RoundedCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.groups_2_outlined, size: 20, color: accent),
            const SizedBox(width: 10),
            Expanded(child: Text(countText)),
            Wrap(
              spacing: -6,
              children: items.map((w) => Container(margin: const EdgeInsets.only(left: 6), child: w)).toList(),
            )
          ],
        ),
      ),
    );
  }
}

extension _PaddingX on Widget {
  Widget paddingOnly({double left = 0, double top = 0, double right = 0, double bottom = 0}) =>
      Padding(padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom), child: this);
}

class _Tabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final Color accent;
  const _Tabs({required this.index, required this.onChanged, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ChoiceChip(
          label: const Text('Description'),
          selected: index == 0,
          selectedColor: accent,
          labelStyle: TextStyle(color: index == 0 ? Colors.white : accent),
          onSelected: (_) => onChanged(0),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('What you need...'),
          selected: index == 1,
          selectedColor: accent,
          labelStyle: TextStyle(color: index == 1 ? Colors.white : accent),
          onSelected: (_) => onChanged(1),
        ),
      ],
    );
  }
}
