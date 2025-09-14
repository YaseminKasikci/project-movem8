// lib/views/maps/maps_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:move_m8/models/community_model.dart';
import 'package:move_m8/models/activity_model.dart' as models;
import 'package:move_m8/services/activity_service.dart';

import '../activity/activity_detail_screen.dart';
import '../../widgets/activity_card_mock.dart';

class MapsScreen extends StatefulWidget {
  final CommunityModel community;

  /// Ouvre directement l’onglet "Liste"
  final bool openListTab;

  /// true = inséré sous une page avec AppBar/BottomNav (CommunityHomeScreen)
  /// false = page autonome (on fournit un Scaffold)
  final bool embedded;

  const MapsScreen({
    Key? key,
    required this.community,
    this.openListTab = false,
    this.embedded = true,
  }) : super(key: key);

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late bool showMap;
  late final ActivityService _service;
  late Future<List<models.ActivityCard>> _future;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR');
    _service = ActivityService();
    showMap = !widget.openListTab; // si openListTab = true → on montre la Liste
    _future = _service.list(communityId: widget.community.id);
  }

  Future<void> _reload() async {
    setState(() => _future = _service.list(communityId: widget.community.id));
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        // ----- Segmented Carte / Liste -----
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Material( // <- ajoute un Material parent (optionnel mais ok)
            color: Colors.transparent,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEAF2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _segment("Carte", showMap, () => setState(() => showMap = true)),
                  _segment("Liste", !showMap, () => setState(() => showMap = false)),
                ],
              ),
            ),
          ),
        ),

        // ----- Recherche + Filtre -----
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  elevation: 0,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Recherche",
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade600, width: 1.2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: panneau de filtres
                },
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text("Filtre"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0E9FA),
                  foregroundColor: const Color(0xFF8E6FD3),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // ----- Corps : Carte OU Liste -----
        Expanded(child: showMap ? _buildMapView() : _buildListView()),
      ],
    );

    // Intégré sous CommunityHomeScreen → pas de Scaffold ici
    if (widget.embedded) return content;

    // Page autonome (au cas où tu l'ouvres seule) → évite l'erreur "No Material widget found"
    return Scaffold(body: SafeArea(child: content));
  }

  // --------- Widgets privés ---------

  Widget _segment(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: Material( // <- indispensable pour InkWell
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: selected ? Colors.black87 : Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    // Remplace par GoogleMap() quand tu intègres la carte
    return const Center(
      child: Text(
        "Carte Google des activités",
        style: TextStyle(color: Colors.black54),
      ),
    );
  }

  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<List<models.ActivityCard>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: 4,
              itemBuilder: (_, __) => const SizedBox(height: 220),
            );
          }
          if (snap.hasError) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text('Erreur: ${snap.error}'),
              ],
            );
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: const [Text('Aucune activité.')],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final a = items[i];
              return ActivityCardMock(
                activity: a,
                onTap: () async {
                  final detail = await _service.getById(a.id);
                  if (!mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ActivityDetailScreen(activity: detail),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
