import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return UserModel.fromDoc(doc);
  }

  Future<List<UserModel>> getAll() async {
    final snap = await _db.collection('users').get();
    return snap.docs.map((doc) => UserModel.fromDoc(doc)).toList();
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

  // CONVERSATIONS
  Future<String> createOrGetConversation(String uid1, String uid2) async {
    final query = await _db
        .collection('conversations')
        .where('participants', arrayContains: uid1)
        .get();

    for (final doc in query.docs) {
      final data = doc.data();
      final participants = List<String>.from(data['participants']);
      if (participants.contains(uid2)) {
        return doc.id;
      }
    }

    final convoRef = _db.collection('conversations').doc();
    await convoRef.set({
      'participants': [uid1, uid2],
      'names': {},
      'lastMessage': '',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return convoRef.id;
  }

  Future<void> setConversationNames(
    String convoId,
    Map<String, String> names,
  ) async {
    await _db.collection('conversations').doc(convoId).update({'names': names});
  }

  Stream<List<Map<String, dynamic>>> getUserConversations() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return _db
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) {
          return snap.docs.map((doc) {
            final data = doc.data();

            final List participants = data['participants'];
            final otherUid = participants.firstWhere((id) => id != uid);

            final otherName = data['names'][otherUid] ?? "Unknown";

            return {
              'convoId': doc.id,
              'uid': otherUid,
              'name': otherName,
              'lastMessage': data['lastMessage'] ?? "",
            };
          }).toList();
        });
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

  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    await _db.collection('events').doc(eventId).update(data);
  }

  Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }

  Future<void> rsvpEvent(String eventId, String uid, String status) async {
    await _db
        .collection('events')
        .doc(eventId)
        .collection('rsvps')
        .doc(uid)
        .set({
          'uid': uid,
          'status': status,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  Stream<List<EventModel>> getPublicEvents() {
    return _db
        .collection('events')
        .where('isPublic', isEqualTo: true)
        .orderBy('date')
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => EventModel.fromDoc(doc)).toList(),
        );
  }
}
