import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String userId;
  final String text;
  final String imageUrl;
  final Timestamp createdAt;

  PostModel({
    required this.postId,
    required this.userId,
    required this.text,
    required this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'text': text,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }

  factory PostModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      postId: data['postId'],
      userId: data['userId'],
      text: data['text'],
      imageUrl: data['imageUrl'],
      createdAt: data['createdAt'],
    );
  }
}
