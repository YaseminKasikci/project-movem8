// 📁 lib/views/messages/messages_screen.dart
import 'package:flutter/material.dart';
import 'package:move_m8/models/community_model.dart';

class MessagesScreen extends StatelessWidget {
    final CommunityModel community;
  const MessagesScreen({Key? key, required this.community}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ici vous chargez les markers / propositions pour community.id
    return Center(child: Text('Carte pour MESSAGE ${community.communityName}'));
  }
}
