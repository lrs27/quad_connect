import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().getUserConversations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No conversations yet"));
        }

        final convos = snapshot.data!;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
              child: const Text(
                "Messages",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: convos.length,
                itemBuilder: (context, i) {
                  final c = convos[i];

                  final participants =
                      c['participants'] as Map<String, dynamic>;
                  final currentUid = FirebaseAuth.instance.currentUser!.uid;

                  // Find the other user
                  final otherUid = participants.keys.firstWhere(
                    (id) => id != currentUid,
                    orElse: () => '',
                  );

                  if (otherUid.isEmpty) {
                    return const ListTile(
                      title: Text("Unknown user"),
                      subtitle: Text("Invalid conversation"),
                    );
                  }

                  final otherName = participants[otherUid] ?? "Unknown";

                  final lastMessage = c['lastMessage'] ?? "";
                  final Timestamp? ts = c['lastTimestamp'];
                  final timeString = ts != null ? _formatTimestamp(ts) : "";

                  // Optional unread indicator
                  final bool unread = c['unread'] == true;

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(otherName[0].toUpperCase()),
                    ),
                    title: Text(
                      otherName,
                      style: TextStyle(
                        fontWeight: unread
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: unread
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: Text(
                      timeString,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            name: otherName,
                            uid: otherUid,
                            convoId: c['convoId'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static String _formatTimestamp(Timestamp ts) {
    final dt = ts.toDate();
    final now = DateTime.now();

    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    }

    return "${dt.month}/${dt.day}/${dt.year}";
  }
}
