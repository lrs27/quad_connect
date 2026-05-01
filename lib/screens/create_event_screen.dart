import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final titleController = TextEditingController();
  final locationController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  bool isPublic = true;
  bool saving = false;
  String? error;

  // -----------------------------
  // PICK DATE
  // -----------------------------
  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // -----------------------------
  // PICK TIME
  // -----------------------------
  Future<void> pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => startTime = picked);
    }
  }

  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => endTime = picked);
    }
  }

  // -----------------------------
  // SAVE EVENT
  // -----------------------------
  Future<void> saveEvent() async {
    if (titleController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        selectedDate == null ||
        startTime == null ||
        endTime == null) {
      setState(() => error = "All fields are required");
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    try {
      final event = {
        'title': titleController.text.trim(),
        'location': locationController.text.trim(),
        'date': Timestamp.fromDate(selectedDate!),
        'startTime': "${startTime!.hour}:${startTime!.minute}",
        'endTime': "${endTime!.hour}:${endTime!.minute}",
        'isPublic': isPublic,
      };

      await FirestoreService().createEvent(event);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => error = "Failed to create event");
    }

    if (mounted) {
      setState(() => saving = false);
    }
  }

  // -----------------------------
  // UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Event")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Event Title"),
            ),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: "Location"),
            ),

            const SizedBox(height: 16),

            // DATE PICKER
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? "No date selected"
                        : "${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}",
                  ),
                ),
                ElevatedButton(
                  onPressed: pickDate,
                  child: const Text("Pick Date"),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // START TIME
            Row(
              children: [
                Expanded(
                  child: Text(
                    startTime == null
                        ? "No start time selected"
                        : startTime!.format(context),
                  ),
                ),
                ElevatedButton(
                  onPressed: pickStartTime,
                  child: const Text("Start Time"),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // END TIME
            Row(
              children: [
                Expanded(
                  child: Text(
                    endTime == null
                        ? "No end time selected"
                        : endTime!.format(context),
                  ),
                ),
                ElevatedButton(
                  onPressed: pickEndTime,
                  child: const Text("End Time"),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text("Public Event"),
              value: isPublic,
              onChanged: (v) => setState(() => isPublic = v),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saving ? null : saveEvent,
              child: saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Create Event"),
            ),
          ],
        ),
      ),
    );
  }
}
