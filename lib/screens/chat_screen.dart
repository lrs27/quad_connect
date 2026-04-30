import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String uid;

  const ChatScreen({super.key, required this.name, required this.uid});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();

  Future<void> send() async {
    if (controller.text.trim().isEmpty) return;

    final user = await AuthService().authStateChanges.first;

    final msg = MessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: user!.uid,
      text: controller.text.trim(),
      createdAt: Timestamp.now(),
    );

    await FirestoreService().sendMessage(widget.uid, msg);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirestoreService().getMessages(widget.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final m = messages[i];
                    final fromMe =
                        m.senderId ==
                        (AuthService().authStateChanges.first as dynamic)?.uid;

                    return Align(
                      alignment: fromMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: fromMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          m.text,
                          style: TextStyle(
                            color: fromMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
