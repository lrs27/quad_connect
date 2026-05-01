import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'post_details_screen.dart';
import 'create_post_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No posts yet"));
          }

          final posts = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, i) {
              final p = posts[i];

              final String text = p['text'] ?? "";
              final String authorName = p['authorName'] ?? "Unknown User";
              final int likes = p['likesCount'] ?? 0;
              final int comments = p['commentsCount'] ?? 0;

              final Timestamp? ts = p['timestamp'];
              final DateTime? date = ts?.toDate();
              final String timeAgo = date != null
                  ? timeago.format(date)
                  : "Unknown time";

              final initials = authorName
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
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailsScreen(post: p),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authorName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  timeAgo,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(text, style: const TextStyle(fontSize: 16)),

                        const SizedBox(height: 12),

                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Image Placeholder",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                FirestoreService().likePost(
                                  p['postId'],
                                  FirestoreService().uid,
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.thumb_up_alt_outlined,
                                    size: 20,
                                    color: Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text("$likes"),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            Icon(
                              Icons.comment_outlined,
                              size: 20,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text("$comments"),

                            const Spacer(),

                            Icon(
                              Icons.share_outlined,
                              size: 20,
                              color: Colors.grey.shade700,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
