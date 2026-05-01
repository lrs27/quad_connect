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
      'likesCount': 0,
      'commentsCount': 0,
    });
  }

  Stream<List<Map<String, dynamic>>> getPosts() {
    return _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) {
          return snap.docs.map((d) {
            final data = d.data();
            data['postId'] = d.id;
            return data;
          }).toList();
        });
  }

  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    await _db.collection('posts').doc(postId).update(data);
  }

  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
  }

  // LIKE / UNLIKE
  Future<void> likePost(String postId, String uid) async {
    final likeRef = _db
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(uid);

    final doc = await likeRef.get();

    if (doc.exists) {
      // Unlike
      await likeRef.delete();
      await _db.collection('posts').doc(postId).update({
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      // Like
      await likeRef.set({'uid': uid});
      await _db.collection('posts').doc(postId).update({
        'likesCount': FieldValue.increment(1),
      });
    }
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

    final existing = await convoRef.where('userIds', arrayContains: uid).get();

    for (var doc in existing.docs) {
      final users = List<String>.from(doc['userIds']);
      if (users.contains(otherUid)) {
        return doc.id;
      }
    }

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
