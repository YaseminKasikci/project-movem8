import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:move_m8/config/api_config.dart';
import 'package:move_m8/models/auth_model.dart';
import 'package:move_m8/models/user_model.dart';
import 'package:move_m8/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_screen.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  UserModel? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
  
      final user = await _userService.getMyProfile();
      setState(() {
        _user = user;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// 🔁 Corrige l’URL de localhost -> 10.0.2.2 pour Android emulator
 String _fixImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  return ApiConfig.fixImageHost(url);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ).then((_) => _loadProfile()); // Recharge après édition
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Erreur : $_error", style: const TextStyle(color: Colors.red)))
              : _user == null
                  ? const Center(child: Text("Profil introuvable"))
                  : _buildProfile(),
    );
  }

  Widget _buildProfile() {
    final imageUrl = _fixImageUrl(_user!.pictureProfile);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            child: imageUrl.isEmpty ? const Icon(Icons.person, size: 60) : null,
          ),
          const SizedBox(height: 16),
          Text("${_user!.firstName} ${_user!.lastName}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_user!.description != null) Text(_user!.description!, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          if (_user!.birthday != null)
           Text("🎂 ${DateFormat('dd/MM/yyyy').format(_user!.birthday!)}"),
          const SizedBox(height: 8),
          Text("Genre : ${_user!.gender ?? "Non défini"}"),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_user!.verifiedProfile == true) const Chip(label: Text("✔️ Profil vérifié")),
              if (_user!.paymentMade == true)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Chip(label: Text("💳 Premium")),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
