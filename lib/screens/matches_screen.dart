import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'chat_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
          child: const Text(
            "Matches",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('matches')
                .where('userIds', arrayContains: currentUid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No matches yet"));
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>?;

                  if (data == null) {
                    return const ListTile(
                      title: Text("Unknown match"),
                      subtitle: Text("Invalid match data"),
                    );
                  }

                  // SAFELY read participants map
                  final participants = data['participants'];
                  if (participants == null ||
                      participants is! Map<String, dynamic>) {
                    return const ListTile(
                      title: Text("Unknown user"),
                      subtitle: Text("Missing participant info"),
                    );
                  }

                  // Find the OTHER user
                  final String otherUid = participants.keys
                      .cast<String>()
                      .firstWhere((id) => id != currentUid, orElse: () => '');

                  if (otherUid.isEmpty) {
                    return const ListTile(
                      title: Text("Invalid match"),
                      subtitle: Text("No other participant found"),
                    );
                  }

                  final String otherName =
                      (participants[otherUid] as String?) ?? "Unknown";

                  // Optional: reason for match
                  final String reason =
                      (data['reason'] as String?) ?? "Matched";

                  // Optional: conversation ID (if exists)
                  final String? convoId = data['convoId'] as String?;
                  String finalConvoId = convoId ?? '';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(otherName[0].toUpperCase()),
                      ),
                      title: Text(otherName),
                      subtitle: Text(reason),
                      onTap: () async {
                        // If convoId exists, use it. Otherwise create a new conversation.
                        if (finalConvoId.isEmpty) {
                          finalConvoId = await FirestoreService().startConversation(
                            otherUid,
                            otherName,
                            "You", // you can swap this for the real current user's name if you store it
                          );

                          // Save convoId back into match doc
                          await docs[i].reference.update({
                            'convoId': finalConvoId,
                          });
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              name: otherName,
                              uid: otherUid,
                              convoId: finalConvoId,
                            ),
                          ),
                        );
                      },
                    ),
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
