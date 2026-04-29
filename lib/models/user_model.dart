import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String major;
  final String year;
  final List<String> courses;
  final List<String> interestTags;
  final List<Map<String, dynamic>> availability;
  final String profilePhotoUrl;
  final String fcmToken;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.major,
    required this.year,
    required this.courses,
    required this.interestTags,
    required this.availability,
    required this.profilePhotoUrl,
    required this.fcmToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'major': major,
      'year': year,
      'courses': courses,
      'interestTags': interestTags,
      'availability': availability,
      'profilePhotoUrl': profilePhotoUrl,
      'fcmToken': fcmToken,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      major: data['major'],
      year: data['year'],
      courses: List<String>.from(data['courses']),
      interestTags: List<String>.from(data['interestTags']),
      availability: List<Map<String, dynamic>>.from(data['availability']),
      profilePhotoUrl: data['profilePhotoUrl'],
      fcmToken: data['fcmToken'],
    );
  }
}
