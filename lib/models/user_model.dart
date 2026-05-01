import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String major;
  final String year;
  final List<String> courses;
  final List<String> interestTags;
  final List<String> availability; // e.g. ["Mon 6–8pm", "Wed 2–4pm"]
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.major,
    required this.year,
    required this.courses,
    required this.interestTags,
    required this.availability,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'major': major,
      'year': year,
      'courses': courses,
      'interestTags': interestTags,
      'availability': availability,
      'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      major: data['major'] ?? '',
      year: data['year'] ?? '',
      courses: List<String>.from(data['courses'] ?? []),
      interestTags: List<String>.from(data['interestTags'] ?? []),
      availability: List<String>.from(data['availability'] ?? []),
      photoUrl: data['photoUrl'],
    );
  }
}
