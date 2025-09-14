// =============================
// lib/views/maps/maps_screen.dart
// =============================
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:move_m8/models/community_model.dart';
import 'package:move_m8/config/api_config.dart';

// MODELS + SERVICE (notre nouvelle API)
import '../../models/activity_model.dart' as models;
import '../../services/activity_service.dart';

// Ton widget de carte (si tu en as un). On l'importe avec un alias pour éviter
// le conflit de nom avec le modèle `ActivityCard`.
import '../../widgets/activityCard.dart' as cards;

class MapsScreen extends StatefulWidget {
  final CommunityModel community;
  const MapsScreen({Key? key, required this.community}) : super(key: key);

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  bool showMap = true;

  late final ActivityService _service;
  late Future<List<models.ActivityCard>> _future; // <-- mini-cards


  @override
  void initState() {
    super.initState();
    // Formats FR (mar., dim., etc.)
    initializeDateFormatting('fr_FR');

 // Instancie le service en utilisant l'ApiConfig basé sur Uri
   // ApiConfig.base == http://<host>:8080/api
    
     _service = ActivityService();

    _future = _service.list(communityId: widget.community.id);
  }

  Future<void> _reload() async {
    setState(() => _future = _service.list(communityId: widget.community.id));
    await _future;
  }

  // Convertit une couleur hex "#RRGGBB" ou "RRGGBB" en Color
  Color _hexToColor(String hex) {
    var cleaned = hex.replaceFirst('#', '');
    if (cleaned.length == 6) cleaned = 'FF$cleaned'; // alpha 100%
    return Color(int.parse(cleaned, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Onglets "Carte" / "Liste"
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildTabButton("Carte", showMap, () {
                setState(() => showMap = true);
              }),
              _buildTabButton("Liste", !showMap, () {
                setState(() => showMap = false);
              }),
            ],
          ),
        ),

        // Barre de recherche + filtre
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "recherche",
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: ouvrir ton panneau de filtres
                },
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text("Filtre"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Vue Map ou Liste
        Expanded(
          child: showMap ? _buildMapView() : _buildListView(),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.black : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    // Intègre ici ton GoogleMap ou ta carte
    return const Center(child: Text("Carte Google des activités"));
  }

  // Liste branchée sur le service mini-cards
  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<List<models.ActivityCard>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 4,
              itemBuilder: (_, __) => const SizedBox(height: 220),
            );
          }
          if (snap.hasError) {
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Erreur: ${snap.error}'),
                ),
              ],
            );
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('Aucune activité.'),
                ),
              ],
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final a = items[i];
              // Si tu as un widget custom pour la carte, utilise-le ici :
              // return cards.ActivityCard(activity: a);

              // Fallback : petite carte simple
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(a.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(a.location),
                      const SizedBox(height: 4),
                      Text('${a.dateHour} • ${a.numberOfParticipant} pers • ${a.note == 0 ? 'Gratuit' : '${a.note.toStringAsFixed(2)}€'}'),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _hexToColor(a.level.color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(a.level.label),
                  ),
                  onTap: () {
                    // TODO: naviguer vers le détail en utilisant a.id
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
