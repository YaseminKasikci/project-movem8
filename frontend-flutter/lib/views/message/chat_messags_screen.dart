import 'package:flutter/material.dart';
import 'package:move_m8/models/community_model.dart';
import '/services/chat_message_service.dart';
import '/models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String currentUserId;
  final CommunityModel community; 

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.currentUserId, 
    required this.community,

  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatMessageService _service = ChatMessageService();
  final TextEditingController _controller = TextEditingController();

  late Future<List<ChatMessage>> _futureMessages;

  @override
  void initState() {
    super.initState();
    _futureMessages = _service.getHistory(widget.conversationId, limit: 50);
  }

  Future<void> _refresh() async {
    final messages = await _service.getHistory(widget.conversationId, limit: 50);
    if (!mounted) return;
    setState(() => _futureMessages = Future.value(messages));
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await _service.sendMessage(
      conversationId: widget.conversationId,
      senderId: widget.currentUserId,
      content: text,
    );
    _controller.clear();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ChatMessage>>(
              future: _futureMessages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Erreur: ${snapshot.error}"));
                }
                final messages = snapshot.data ?? [];

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    reverse: false,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      final isMine = m.senderId == widget.currentUserId;

                      return Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: isMine
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(m.content),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Écrire un message…",
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
