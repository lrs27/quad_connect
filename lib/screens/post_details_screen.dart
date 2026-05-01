import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class PostDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailsScreen({super.key, required this.post});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  bool editing = false;
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.post['text']);
  }

  @override
  Widget build(BuildContext context) {
    final postId = widget.post['postId'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => setState(() => editing = !editing),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await FirestoreService().deletePost(postId);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: editing
            ? Column(
                children: [
                  TextField(controller: textController, maxLines: 5),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await FirestoreService().updatePost(postId, {
                        'text': textController.text.trim(),
                      });
                      setState(() => editing = false);
                    },
                    child: const Text("Save Changes"),
                  ),
                ],
              )
            : Text(widget.post['text'], style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
