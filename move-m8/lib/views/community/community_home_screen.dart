
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/auth_model.dart';
import '../../models/community_model.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/plus_fab.dart';

// Onglets
import '../nav_bar/maps_screen.dart';
import '../nav_bar/notification_screen.dart';
import '../nav_bar/messages_screen.dart';
import '../nav_bar/historic_screen.dart';
import '../nav_bar/create_activity_screen.dart';

// Sélecteur de communauté (picker)
import '../community/community_selection_screen.dart';

class CommunityHomeScreen extends StatefulWidget {
  final CommunityModel community;

  /// 0=Maps, 1=Fav, 2=Create(FAB), 3=Msg, 4=Historic
  final int initialIndex;

  /// Si true => Maps démarre directement sur l’onglet "Liste"
  final bool mapsOpenListTab;

  const CommunityHomeScreen({
    Key? key,
    required this.community,
    this.initialIndex = 0,
    this.mapsOpenListTab = false,
  }) : super(key: key);

  @override
  State<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends State<CommunityHomeScreen> {
  late int _currentIndex;
  late CommunityModel _current;
  late List<Widget> _pages;

  /// Flag éphémère pour ouvrir Maps > Liste juste après une création
  bool _openListAfterCreate = false;

  @override
  void initState() {
    super.initState();
    _current = widget.community;
    _currentIndex = widget.initialIndex;
    _rebuildPages();
  }

  void _rebuildPages() {
    // Si on doit ouvrir la liste : mapsOpenListTab (prop) OU _openListAfterCreate (runtime)
    final openList = widget.mapsOpenListTab || _openListAfterCreate;

    _pages = [
      MapsScreen(
        community: _current,
        openListTab: openList,
        embedded: true, // intégré dans ce Scaffold (AppBar + BottomNav)
      ),
      NotificationScreen(community: _current),

      // Slot central réservé au FAB (+) -> on met un placeholder
      const SizedBox.shrink(),

      MessagesScreen(community: _current),
      HistoricScreen(community: _current),
    ];
  }

  Future<void> _openCommunitySelector() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session expirée. Reconnectez-vous.")),
      );
      return;
    }
    final auth = AuthModel.fromJson(jsonDecode(userJson));

    final selected = await Navigator.push<CommunityModel>(
      context,
      MaterialPageRoute(
        builder: (_) => CommunitySelectionScreen(
          user: auth,
          pickMode: true,
        ),
      ),
    );

    if (!mounted) return;
    if (selected != null) {
      setState(() {
        _current = selected;
        _currentIndex = 0;           
        _openListAfterCreate = false; 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Communauté changée : ${selected.communityName}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(_current.communityName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
       
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: PlusFAB(
        heroTag: 'mainFAB',
        onPressed: () async {
          // Ouvre la création modale. La page de création doit faire "Navigator.pop(context, true)"
          // quand l’activité est créée avec succès.
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => CreateActivityScreen(community: _current),
            ),
          );

          if (!mounted) return;
          if (created == true) {
            // Revenir sur Maps et ouvrir directement l’onglet Liste
            setState(() {
              _currentIndex = 0;
              _openListAfterCreate = true;
              _rebuildPages();          // reconstruit MapsScreen avec openListTab=true
              _openListAfterCreate = false; // reset pour la prochaine fois
            });
          }
        },
      ),

      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 2) return; // l’index 2 est réservé au gros FAB
          setState(() => _currentIndex = i);
        },
      ),
    );
  }
}
