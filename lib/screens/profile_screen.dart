import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<UserModel?> loadUser() async {
    final user = await AuthService().authStateChanges.first;
    return FirestoreService().getUser(user!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data as UserModel;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(radius: 40, child: Icon(Icons.person)),
              const SizedBox(height: 12),

              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("${user.major} • ${user.year}"),

              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Courses",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Wrap(
                spacing: 8,
                children: user.courses
                    .map((c) => Chip(label: Text(c)))
                    .toList(),
              ),

              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Interests",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Wrap(
                spacing: 8,
                children: user.interestTags
                    .map((t) => Chip(label: Text(t)))
                    .toList(),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () async {
                  await AuthService().logout();
                },
                child: const Text("Logout"),
              ),
            ],
          ),
        );
      },
    );
  }
}
