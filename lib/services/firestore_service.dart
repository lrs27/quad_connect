import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/message_model.dart';
import '../models/event_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // USERS
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return UserModel.fromDoc(doc);
  }

  // POSTS
  Future<void> createPost(PostModel post) async {
    await _db.collection('posts').doc(post.postId).set(post.toMap());
  }

  Stream<List<PostModel>> getPosts() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => PostModel.fromDoc(doc)).toList());
  }

  // MESSAGES
  Future<void> sendMessage(String convoId, MessageModel message) async {
    await _db
        .collection('conversations')
        .doc(convoId)
        .collection('messages')
        .doc(message.messageId)
        .set(message.toMap());

    await _db.collection('conversations').doc(convoId).update({
      'lastMessage': message.text,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<MessageModel>> getMessages(String convoId) {
    return _db
        .collection('conversations')
        .doc(convoId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => MessageModel.fromDoc(doc)).toList(),
        );
  }

  // EVENTS
  Future<void> createEvent(EventModel event) async {
    await _db.collection('events').doc(event.eventId).set(event.toMap());
  }

  Stream<List<EventModel>> getEvents() {
    return _db
        .collection('events')
        .orderBy('date')
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => EventModel.fromDoc(doc)).toList(),
        );
  }

  Future<void> rsvpEvent(String eventId, String uid, String status) async {
    await _db
        .collection('events')
        .doc(eventId)
        .collection('rsvps')
        .doc(uid)
        .set({'status': status, 'timestamp': FieldValue.serverTimestamp()});
  }
}
