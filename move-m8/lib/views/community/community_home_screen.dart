// 📁 lib/views/community/community_home_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:move_m8/views/nav_bar/historic_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/auth_model.dart';
import '../../models/community_model.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/plus_fab.dart';

// Onglets
import '../nav_bar/maps_screen.dart';
import '../nav_bar/favorites_screen.dart';
import '../nav_bar/messages_screen.dart';
import '../nav_bar/create_activity_screen.dart';


// Sélecteur de communauté (avec pickMode)
import '../community/community_selection_screen.dart';

class CommunityHomeScreen extends StatefulWidget {
  final CommunityModel community;
  const CommunityHomeScreen({Key? key, required this.community})
      : super(key: key);

  @override
  State<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends State<CommunityHomeScreen> {
  int _currentIndex = 0;

  late CommunityModel _current; // communauté courante
  late List<Widget> _pages;     // pages dépendantes de la communauté

  @override
  void initState() {
    super.initState();
    _current = widget.community;
    _rebuildPages();
  }

  void _rebuildPages() {
    _pages = [
      MapsScreen(community: _current),
      FavoritesScreen(community: _current),
      CreateActivityScreen(community: _current),
      MessagesScreen(community: _current),
      HistoricScreen(community: _current)

    ];
  }

  Future<void> _openCommunitySelector() async {
    // Récupérer l'AuthModel stocké après login/2FA
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

    // Ouvre l’écran de sélection en mode “picker” et attend le résultat
    final selected = await Navigator.push<CommunityModel>(
      context,
      MaterialPageRoute(
        builder: (_) => CommunitySelectionScreen(
          user: auth,
          pickMode: true, // renverra la communauté choisie via pop()
        ),
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _current = selected;
        _rebuildPages();
        _currentIndex = 0; // optionnel: revient au premier onglet
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
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: PlusFAB(
        heroTag: 'mainFAB',
        onPressed: () => setState(() => _currentIndex = 2),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 2) return; // géré par le FAB
          setState(() => _currentIndex = i);
        },
      ),
    );
  }
}
