import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top bar (replaces AppBar)
        Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
          child: const Text(
            "Messages",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),

        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirestoreService().getUserConversations(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final convos = snapshot.data!;

              if (convos.isEmpty) {
                return const Center(child: Text("No conversations yet"));
              }

              return ListView.builder(
                itemCount: convos.length,
                itemBuilder: (context, i) {
                  final c = convos[i];

                  return ListTile(
                    leading: CircleAvatar(child: Text(c['name'][0])),
                    title: Text(c['name']),
                    subtitle: Text(c['lastMessage']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            name: c['name'],
                            uid: c['uid'],
                            convoId: c['convoId'],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
