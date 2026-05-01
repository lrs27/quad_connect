import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/matching_service.dart';
import '../models/user_model.dart';
import 'chat_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  Future<List<Map<String, dynamic>>> loadMatches() async {
    final current = FirebaseAuth.instance.currentUser!;

    // Load YOUR user data as UserModel
    final meData = await FirestoreService().getUser(current.uid);
    final me = UserModel.fromMap(meData!);

    // Load all users
    final allUsers = await FirestoreService().getAll();
    final matcher = MatchingService();

    final matches = <Map<String, dynamic>>[];

    for (final u in allUsers) {
      if (u.uid == me.uid) continue;

      final score = matcher.calculateScore(
        userCourses: me.courses,
        otherCourses: u.courses,
        userTags: me.interestTags,
        otherTags: u.interestTags,
      );

      final sharedCourses = me.courses
          .where((c) => u.courses.contains(c))
          .toList();

      final sharedTags = me.interestTags
          .where((t) => u.interestTags.contains(t))
          .toList();

      matches.add({
        'user': u,
        'score': score,
        'sharedCourses': sharedCourses,
        'sharedTags': sharedTags,
      });
    }

    matches.sort((a, b) => b['score'].compareTo(a['score']));
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Matches")),

      body: FutureBuilder(
        future: loadMatches(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final matches = snapshot.data as List<Map<String, dynamic>>;

          if (matches.isEmpty) {
            return const Center(child: Text("No matches found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            itemBuilder: (context, i) {
              final u = matches[i]['user'] as UserModel;
              final score = matches[i]['score'];
              final sharedCourses = matches[i]['sharedCourses'] as List;
              final sharedTags = matches[i]['sharedTags'] as List;

              final initials = u.name
                  .trim()
                  .split(" ")
                  .map((e) => e[0])
                  .take(2)
                  .join()
                  .toUpperCase();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),

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
                    u.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        "Match Score: $score%",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      if (sharedCourses.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          "Shared Courses: ${sharedCourses.join(", ")}",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],

                      if (sharedTags.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Shared Interests: ${sharedTags.join(", ")}",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ],
                  ),

                  onTap: () async {
                    // Load YOUR name correctly
                    final meData = await FirestoreService().getUser(
                      FirebaseAuth.instance.currentUser!.uid,
                    );
                    final myName = meData?['name'] ?? "Unknown";

                    // Start conversation with correct names
                    final convoId = await FirestoreService().startConversation(
                      u.uid, // other user UID
                      u.name, // other user name
                      myName, // YOUR name (correct)
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          name: u.name,
                          uid: u.uid,
                          convoId: convoId,
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
    );
  }
}
