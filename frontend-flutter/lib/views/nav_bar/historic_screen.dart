// 📁 lib/views/Historic_screen.dart
import 'package:flutter/material.dart';
import 'package:move_m8/models/community_model.dart';

class HistoricScreen extends StatelessWidget {
  final CommunityModel community;
  const HistoricScreen({Key? key, required this.community}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ici vous chargez les markers / propositions pour community.id
    return Center(child: Text('Carte pour HISTORIC ${community.communityName}'));
  }
}
