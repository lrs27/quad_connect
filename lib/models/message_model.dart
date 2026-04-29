import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String text;
  final Timestamp createdAt;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'text': text,
      'createdAt': createdAt,
    };
  }

  factory MessageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      messageId: data['messageId'],
      senderId: data['senderId'],
      text: data['text'],
      createdAt: data['createdAt'],
    );
  }
}
