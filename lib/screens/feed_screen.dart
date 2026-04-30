import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/post_model.dart';
import 'matches_screen.dart';
import 'chat_list_screen.dart';
import 'events_screen.dart';
import 'profile_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int index = 0;

  final pages = const [
    FeedBody(),
    MatchesScreen(),
    ChatListScreen(),
    EventsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Matches"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class FeedBody extends StatelessWidget {
  const FeedBody({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PostModel>>(
      stream: FirestoreService().getPosts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: const Text("QuadConnect")),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, i) {
              final p = posts[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.text),
                      const SizedBox(height: 8),
                      Text(
                        p.createdAt.toDate().toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
