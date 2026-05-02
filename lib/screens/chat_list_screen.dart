import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'chat_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  // ------------------------------------------------------------
  // REUSABLE CONVERSATION TILE (Unread Badge)
  // ------------------------------------------------------------
  Widget buildConversationTile({
    required String name,
    required String lastMessage,
    required String timeAgo,
    required int unreadCount,
  }) {
    final initials = name
        .trim()
        .split(" ")
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            child: Text(
              initials,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(width: 12),

          // Name + message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  lastMessage.isEmpty ? "No messages yet" : lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: unreadCount > 0
                        ? Colors.black
                        : Colors.grey.shade600,
                    fontWeight: unreadCount > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Time + unread badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeAgo,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 6),

              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MAIN UI
  // ------------------------------------------------------------
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
            padding: const EdgeInsets.all(16),
            itemCount: conversations.length,
            itemBuilder: (context, i) {
              final convo = conversations[i];

              final participants = Map<String, dynamic>.from(
                convo['participants'],
              );

              final otherUid = participants.keys.firstWhere((id) => id != uid);

              final otherName = participants[otherUid] ?? "Unknown User";

              final lastMessage = convo['lastMessage'] ?? "";

              final Timestamp? ts = convo['lastTimestamp'];
              final date = ts?.toDate();
              final timeAgo = date != null
                  ? timeago.format(date)
                  : "Unknown time";

              final unreadCount = convo['unreadCount']?[uid] ?? 0;

              return InkWell(
                onTap: () {
                  // Reset unread count when opening chat
                  FirebaseFirestore.instance
                      .collection("conversations")
                      .doc(convo['convoId'])
                      .update({"unreadCount.$uid": 0});

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
                child: buildConversationTile(
                  name: otherName,
                  lastMessage: lastMessage,
                  timeAgo: timeAgo,
                  unreadCount: unreadCount,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
