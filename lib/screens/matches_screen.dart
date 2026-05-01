import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/matching_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'chat_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  Future<List<Map<String, dynamic>>> loadMatches() async {
    final current = await AuthService().authStateChanges.first;
    final me = await FirestoreService().getUser(current!.uid);

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

      matches.add({'user': u, 'score': score});
    }

    matches.sort((a, b) => b['score'].compareTo(a['score']));
    return matches.take(5).toList();
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            itemBuilder: (context, i) {
              final u = matches[i]['user'] as UserModel;
              final score = matches[i]['score'];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(u.name),
                  subtitle: Text("${u.major} • ${u.year}"),
                  trailing: Text("$score%"),
                  onTap: () async {
                    final current = await AuthService().authStateChanges.first;
                    final me = matches[i]['me'] as UserModel;

                    final convoId = await FirestoreService()
                        .createOrGetConversation(current!.uid, u.uid);

                    await FirestoreService().setConversationNames(convoId, {
                      current.uid: me.name,
                      u.uid: u.name,
                    });

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
