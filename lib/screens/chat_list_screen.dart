import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'chat_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Chats")),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().getUserConversations(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversations = snapshot.data!;

          if (conversations.isEmpty) {
            return const Center(child: Text("No conversations yet"));
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, i) {
              final convo = conversations[i];

              final participants = Map<String, dynamic>.from(
                convo['participants'],
              );

              final otherUid = participants.keys.firstWhere((id) => id != uid);

              final otherName = participants[otherUid] ?? "Unknown User";

              final initials = otherName
                  .trim()
                  .split(" ")
                  .map((e) => e[0])
                  .take(2)
                  .join()
                  .toUpperCase();

              final lastMessage = convo['lastMessage'] ?? "";

              final Timestamp? ts = convo['lastTimestamp'];
              final date = ts?.toDate();
              final timeAgo = date != null
                  ? timeago.format(date)
                  : "Unknown time";

              return ListTile(
                leading: CircleAvatar(
                  radius: 22,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                title: Text(
                  otherName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                subtitle: Text(
                  lastMessage.isEmpty ? "No messages yet" : lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                trailing: Text(
                  timeAgo,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        name: otherName,
                        uid: otherUid,
                        convoId: convo['convoId'],
                      ),
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
