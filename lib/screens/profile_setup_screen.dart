import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _majorController = TextEditingController();
  final _yearController = TextEditingController();
  final _coursesController = TextEditingController();
  final _interestsController = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _majorController.dispose();
    _yearController.dispose();
    _coursesController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  Future<void> _finishSetup() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final currentUser = await AuthService().authStateChanges.first;

      if (currentUser == null) {
        setState(() => _error = "User not logged in");
        return;
      }

      final model = UserModel(
        uid: currentUser.uid,
        name: currentUser.email!.split('@')[0],
        email: currentUser.email!,
        major: _majorController.text.trim(),
        year: _yearController.text.trim(),
        courses: _coursesController.text
            .split(',')
            .map((e) => e.trim())
            .toList(),
        interestTags: _interestsController.text
            .split(',')
            .map((e) => e.trim())
            .toList(),
        availability: [],
        profilePhotoUrl: "",
        fcmToken: "",
      );

      await FirestoreService().createUser(model);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() => _error = "Failed to save profile: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Setup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),

            TextField(
              controller: _majorController,
              decoration: const InputDecoration(labelText: "Major"),
            ),

            TextField(
              controller: _yearController,
              decoration: const InputDecoration(labelText: "Year"),
            ),

            TextField(
              controller: _coursesController,
              decoration: const InputDecoration(
                labelText: "Courses (comma separated)",
              ),
            ),

            TextField(
              controller: _interestsController,
              decoration: const InputDecoration(
                labelText: "Interests (comma separated)",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _loading ? null : _finishSetup,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Finish Setup"),
            ),
          ],
        ),
      ),
    );
  }
}
