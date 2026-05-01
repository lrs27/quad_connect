import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final nameController = TextEditingController();
  final majorController = TextEditingController();
  final yearController = TextEditingController();
  final coursesController = TextEditingController(); // comma-separated
  final interestsController = TextEditingController(); // comma-separated
  final availabilityController = TextEditingController(); // comma-separated

  bool saving = false;
  String? error;

  Future<void> saveProfile() async {
    setState(() {
      saving = true;
      error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final uid = user.uid;

      // Convert comma-separated fields into lists
      List<String> courses = coursesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      List<String> interests = interestsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      List<String> availability = availabilityController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Build user data map (matches new UserModel + FirestoreService)
      final data = {
        'uid': uid,
        'email': user.email ?? '',
        'name': nameController.text.trim(),
        'major': majorController.text.trim(),
        'year': yearController.text.trim(),
        'courses': courses,
        'interestTags': interests,
        'availability': availability,
        'photoUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirestoreService().createUser(data);

      if (!mounted) return;

      // Navigate to home (bottom nav)
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        error = "Failed to save profile. Please try again.";
      });
    }

    if (mounted) {
      setState(() {
        saving = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    majorController.dispose();
    yearController.dispose();
    coursesController.dispose();
    interestsController.dispose();
    availabilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Up Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            TextField(
              controller: majorController,
              decoration: const InputDecoration(labelText: "Major"),
            ),

            TextField(
              controller: yearController,
              decoration: const InputDecoration(labelText: "Year"),
            ),

            TextField(
              controller: coursesController,
              decoration: const InputDecoration(
                labelText: "Courses (comma-separated)",
              ),
            ),

            TextField(
              controller: interestsController,
              decoration: const InputDecoration(
                labelText: "Interests (comma-separated)",
              ),
            ),

            TextField(
              controller: availabilityController,
              decoration: const InputDecoration(
                labelText: "Availability (comma-separated)",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saving ? null : saveProfile,
              child: saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save & Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
