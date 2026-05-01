import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return await FirestoreService().getUser(uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data;

        if (data == null) {
          return const Center(child: Text("Profile not found"));
        }

        final String name = data['name'] ?? "No name";
        final String email = data['email'] ?? "";
        final String major = data['major'] ?? "";
        final String year = data['year'] ?? "";
        final List courses = data['courses'] ?? [];
        final List interests = data['interestTags'] ?? [];
        final List availability = data['availability'] ?? [];
        final String? photoUrl = data['photoUrl'];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -----------------------
              // HEADER
              // -----------------------
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "?",
                            style: const TextStyle(fontSize: 32),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        if (major.isNotEmpty || year.isNotEmpty)
                          Text("$major • $year"),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // -----------------------
              // COURSES
              // -----------------------
              if (courses.isNotEmpty) ...[
                const Text(
                  "Courses",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: courses
                      .map((c) => Chip(label: Text(c.toString())))
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],

              // -----------------------
              // INTERESTS
              // -----------------------
              if (interests.isNotEmpty) ...[
                const Text(
                  "Interests",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: interests
                      .map((i) => Chip(label: Text(i.toString())))
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],

              // -----------------------
              // AVAILABILITY
              // -----------------------
              if (availability.isNotEmpty) ...[
                const Text(
                  "Availability",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: availability
                      .map((a) => Chip(label: Text(a.toString())))
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
