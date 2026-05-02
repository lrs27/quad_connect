import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Map<String, dynamic>?> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return await FirestoreService().getUser(uid);
  }

  void _addItemDialog({
    required String title,
    required Function(String) onAdd,
  }) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add $title"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter $title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onAdd(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateField(String field, List updatedList) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      field: updatedList,
    });
    setState(() {}); // refresh UI
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
        final List courses = List.from(data['courses'] ?? []);
        final List interests = List.from(data['interestTags'] ?? []);
        final List availability = List.from(data['availability'] ?? []);
        final String? photoUrl = data['photoUrl'];

        return Scaffold(
          appBar: AppBar(title: const Text("Profile"), centerTitle: true),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // -----------------------
                // PROFILE PHOTO
                // -----------------------
                CircleAvatar(
                  radius: 60,
                  backgroundImage: photoUrl != null
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: const TextStyle(fontSize: 50),
                        )
                      : null,
                ),

                const SizedBox(height: 16),

                // -----------------------
                // NAME + EMAIL + MAJOR/YEAR
                // -----------------------
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (email.isNotEmpty)
                  Text(
                    email,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),

                if (major.isNotEmpty || year.isNotEmpty)
                  Text(
                    "$major • $year",
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 40),

                // -----------------------
                // COURSES SECTION
                // -----------------------
                _buildEditableSection(
                  title: "Courses",
                  items: courses,
                  fieldName: "courses",
                ),

                const SizedBox(height: 30),

                // -----------------------
                // INTERESTS SECTION
                // -----------------------
                _buildEditableSection(
                  title: "Interests",
                  items: interests,
                  fieldName: "interestTags",
                ),

                const SizedBox(height: 30),

                // -----------------------
                // AVAILABILITY SECTION
                // -----------------------
                _buildEditableSection(
                  title: "Availability",
                  items: availability,
                  fieldName: "availability",
                ),

                const SizedBox(height: 40),

                // -----------------------
                // LOGOUT BUTTON
                // -----------------------
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 203, 243, 246),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Logout"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -----------------------
  // REUSABLE EDITABLE SECTION
  // -----------------------
  Widget _buildEditableSection({
    required String title,
    required List items,
    required String fieldName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _addItemDialog(
                  title: title.substring(0, title.length - 1),
                  onAdd: (value) {
                    items.add(value);
                    _updateField(fieldName, items);
                  },
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items
              .map(
                (item) => Chip(
                  label: Text(item.toString()),
                  onDeleted: () {
                    items.remove(item);
                    _updateField(fieldName, items);
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
