import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // ------------------------------------------------------------
  // USERS
  // ------------------------------------------------------------
  Future<void> createUser(Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  // ------------------------------------------------------------
  // POSTS
  // ------------------------------------------------------------
  Future<void> createPost(Map<String, dynamic> post) async {
    await _db.collection('posts').add({
      ...post,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getPosts() {
    return _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  // ------------------------------------------------------------
  // CONVERSATIONS
  // ------------------------------------------------------------
  Future<String> startConversation(
    String otherUid,
    String otherName,
    String myName,
  ) async {
    final convoRef = _db.collection('conversations');

    // Check if conversation already exists
    final existing = await convoRef.where('userIds', arrayContains: uid).get();

    for (var doc in existing.docs) {
      final users = List<String>.from(doc['userIds']);
      if (users.contains(otherUid)) {
        return doc.id;
      }
    }

    // Create new conversation
    final newConvo = await convoRef.add({
      'userIds': [uid, otherUid],
      'participants': {uid: myName, otherUid: otherName},
      'lastMessage': '',
      'lastTimestamp': FieldValue.serverTimestamp(),
    });

    return newConvo.id;
  }

  Stream<List<Map<String, dynamic>>> getUserConversations() {
    return _db
        .collection('conversations')
        .where('userIds', arrayContains: uid)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .map((snap) {
          return snap.docs.map((doc) {
            final data = doc.data();

            final participants = data['participants'] ?? {};
            final otherUid = participants.keys.firstWhere(
              (id) => id != uid,
              orElse: () => null,
            );

            return {
              'convoId': doc.id,
              'participants': participants,
              'lastMessage': data['lastMessage'] ?? '',
            };
          }).toList();
        });
  }

  // ------------------------------------------------------------
  // MESSAGES
  // ------------------------------------------------------------
  Future<void> sendMessage(
    String convoId,
    String text,
    String receiverUid,
  ) async {
    final convoRef = _db.collection('conversations').doc(convoId);

    await convoRef.collection('messages').add({
      'sender': uid,
      'receiver': receiverUid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await convoRef.update({
      'lastMessage': text,
      'lastTimestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getMessages(String convoId) {
    return _db
        .collection('conversations')
        .doc(convoId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  // ------------------------------------------------------------
  // EVENTS
  // ------------------------------------------------------------
  Future<void> createEvent(Map<String, dynamic> event) async {
    final docRef = await _db.collection('events').add({
      ...event,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Save eventId inside the document for easy access
    await docRef.update({'eventId': docRef.id});
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    await _db.collection('events').doc(eventId).update(data);
  }

  Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }

  Stream<List<Map<String, dynamic>>> getPublicEvents() {
    return _db
        .collection('events')
        .where('isPublic', isEqualTo: true)
        .orderBy('date')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
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
}
