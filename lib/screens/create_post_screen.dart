import 'package:flutter/material.dart';
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

                      // Get user profile info
                      final user = await FirestoreService().getUser(
                        FirestoreService().uid,
                      );

                      await FirestoreService().createPost({
                        'text': controller.text.trim(),
                        'authorUid': FirestoreService().uid,
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
