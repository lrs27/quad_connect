import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // SAFE UID getter
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // ------------------------------------------------------------
  // USERS
  // ------------------------------------------------------------
  Future<void> createUser(Map<String, dynamic> data) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<List<UserModel>> getAll() async {
    final snap = await _db.collection('users').get();
    return snap.docs.map((d) => UserModel.fromMap(d.data())).toList();
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
      await likeRef.delete();
      await _db.collection('posts').doc(postId).update({
        'likesCount': FieldValue.increment(-1),
      });
    } else {
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
    if (uid == null) throw Exception("User not logged in");

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
      'participants': {uid!: myName, otherUid: otherName},
      'lastMessage': '',
      'lastTimestamp': FieldValue.serverTimestamp(),
      'unreadCount': {uid!: 0, otherUid: 0},
    });

    return newConvo.id;
  }

  Stream<List<Map<String, dynamic>>> getUserConversations() {
    if (uid == null) {
      return const Stream.empty();
    }

    return _db
        .collection('conversations')
        .where('userIds', arrayContains: uid)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .map((snap) {
          return snap.docs.map((doc) {
            final data = doc.data();

            final participants = Map<String, dynamic>.from(
              data['participants'] ?? {},
            );

            final otherUid = participants.keys.firstWhere(
              (id) => id != uid,
              orElse: () => "",
            );

            return {
              'convoId': doc.id,
              'participants': participants,
              'lastMessage': data['lastMessage'] ?? '',
              'lastTimestamp': data['lastTimestamp'],
              'unreadCount': data['unreadCount'] ?? {}, // ⭐ REQUIRED
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
    if (uid == null) return;

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
      'unreadCount.$receiverUid': FieldValue.increment(1),
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
    if (uid == null) return;

    final docRef = await _db.collection('events').add({
      ...event,
      'createdBy': uid,
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

  Future<void> rsvpToEvent(String eventId, String uid, String name) async {
    final eventRef = FirebaseFirestore.instance
        .collection("events")
        .doc(eventId);

    await eventRef.collection("rsvps").doc(uid).set({
      "name": name,
      "timestamp": FieldValue.serverTimestamp(),
    });

    await eventRef.update({"goingCount": FieldValue.increment(1)});
  }

  Future<void> cancelRsvp(String eventId, String uid) async {
    final eventRef = FirebaseFirestore.instance
        .collection("events")
        .doc(eventId);

    await eventRef.collection("rsvps").doc(uid).delete();

    await eventRef.update({"goingCount": FieldValue.increment(-1)});
  }
}
