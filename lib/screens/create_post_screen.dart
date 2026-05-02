import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final controller = TextEditingController();
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Write something...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      setState(() => saving = true);

                      // SAFE UID
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) return;

                      // Get user profile info
                      final user = await FirestoreService().getUser(uid);

                      await FirestoreService().createPost({
                        'text': controller.text.trim(),
                        'authorUid': uid,
                        'authorName': user?['name'] ?? "Unknown User",
                      });

                      if (context.mounted) Navigator.pop(context);
                    },
              child: saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Post"),
            ),
          ],
        ),
      ),
    );
  }
}
