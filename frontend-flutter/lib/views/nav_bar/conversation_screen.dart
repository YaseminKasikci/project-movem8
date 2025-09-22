import 'package:flutter/material.dart';
import 'package:move_m8/models/community_model.dart';
import 'package:move_m8/models/chat_message.dart';
import 'package:move_m8/services/chat_message_service.dart';
import '../message/chat_messags_screen.dart'; 

class ConversationsScreen extends StatefulWidget {
  final CommunityModel community;
  final String currentUserId;

  const ConversationsScreen({
    super.key,
    required this.community,
    required this.currentUserId,
  });

  @override
  State<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState
    extends State<ConversationsScreen> {
  final ChatMessageService _service = ChatMessageService();

  late Future<List<ChatMessage>> _futureConversations;

  @override
  void initState() {
    super.initState();
    _futureConversations =
        _service.listConversations(widget.community.id, limit: 50);
  }

  Future<void> _refresh() async {
    final convs =
        await _service.listConversations(widget.community.id, limit: 50);
    if (!mounted) return;
    setState(() => _futureConversations = Future.value(convs));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Messages - ${widget.community.communityName}")),
      body: FutureBuilder<List<ChatMessage>>(
        future: _futureConversations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }
          final convs = snapshot.data ?? [];
          if (convs.isEmpty) {
            return const Center(child: Text("Aucune conversation pour l’instant"));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              itemCount: convs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final c = convs[i];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (c.creatorPhotoUrl != null &&
                            c.creatorPhotoUrl!.isNotEmpty)
                        ? NetworkImage(c.creatorPhotoUrl!)
                        : null,
                    child: (c.creatorPhotoUrl == null ||
                            c.creatorPhotoUrl!.isEmpty)
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    "${c.creatorFirstName ?? ''} ${c.creatorLastName ?? ''}".trim(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${c.sportName ?? ''} · ${c.content}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          conversationId: c.conversationId,
                          currentUserId: widget.currentUserId,
                          community: widget.community,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
