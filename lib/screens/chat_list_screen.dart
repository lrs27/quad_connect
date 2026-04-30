import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().authStateChanges.first;

    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),
      body: StreamBuilder(
        stream: FirestoreService().getUserConversations(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final convos = snapshot.data!;

          return ListView.builder(
            itemCount: convos.length,
            itemBuilder: (context, i) {
              final c = convos[i];

              return ListTile(
                title: Text(c['name']),
                subtitle: Text(c['lastMessage']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ChatScreen(name: c['name'], uid: c['uid']),
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
