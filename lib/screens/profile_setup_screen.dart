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
  String? selectedYear;

  List<String> courses = [];
  List<String> interests = [];
  List<String> availability = [];

  bool saving = false;
  String? error;

  final List<String> yearOptions = [
    "Freshman",
    "Sophomore",
    "Junior",
    "Senior",
    "Graduate",
  ];

  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

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

  Future<void> saveProfile() async {
    setState(() {
      saving = true;
      error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final uid = user.uid;

      final data = {
        'uid': uid,
        'email': user.email ?? '',
        'name': nameController.text.trim(),
        'major': majorController.text.trim(),
        'year': selectedYear ?? "",
        'courses': courses,
        'interestTags': interests,
        'availability': availability,
        'photoUrl': null,
      };

      await FirestoreService().createUser(data);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() => error = "Failed to save profile. Please try again.");
    }

    if (mounted) setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Setup")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 20),

            // -----------------------
            // NAME
            // -----------------------
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // -----------------------
            // MAJOR
            // -----------------------
            TextField(
              controller: majorController,
              decoration: const InputDecoration(
                labelText: "Major",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // -----------------------
            // YEAR DROPDOWN
            // -----------------------
            DropdownButtonFormField<String>(
              value: selectedYear,
              decoration: const InputDecoration(
                labelText: "Year",
                border: OutlineInputBorder(),
              ),
              items: yearOptions
                  .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                  .toList(),
              onChanged: (value) => setState(() => selectedYear = value),
            ),

            const SizedBox(height: 30),

            // -----------------------
            // COURSES
            // -----------------------
            const Text(
              "Courses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [
                ...courses.map(
                  (c) => Chip(
                    label: Text(c),
                    onDeleted: () => setState(() => courses.remove(c)),
                  ),
                ),
                ActionChip(
                  label: const Text("+ Add"),
                  onPressed: () => _addItemDialog(
                    title: "Course",
                    onAdd: (value) => setState(() => courses.add(value)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // -----------------------
            // INTERESTS
            // -----------------------
            const Text(
              "Interests",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [
                ...interests.map(
                  (i) => Chip(
                    label: Text(i),
                    onDeleted: () => setState(() => interests.remove(i)),
                  ),
                ),
                ActionChip(
                  label: const Text("+ Add"),
                  onPressed: () => _addItemDialog(
                    title: "Interest",
                    onAdd: (value) => setState(() => interests.add(value)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // -----------------------
            // AVAILABILITY
            // -----------------------
            const Text(
              "Availability",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 10,
              children: days.map((day) {
                final selected = availability.contains(day);
                return ChoiceChip(
                  label: Text(day),
                  selected: selected,
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                  ),
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        availability.add(day);
                      } else {
                        availability.remove(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 40),

            // -----------------------
            // SAVE BUTTON
            // -----------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : saveProfile,
                child: saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Complete Profile"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
