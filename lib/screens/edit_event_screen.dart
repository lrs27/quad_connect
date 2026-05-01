import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class EditEventScreen extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> data;

  const EditEventScreen({super.key, required this.eventId, required this.data});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController titleController;
  late TextEditingController locationController;

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  bool isPublic = true;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.data['title']);
    locationController = TextEditingController(text: widget.data['location']);

    final Timestamp? ts = widget.data['date'];
    selectedDate = ts?.toDate();

    final start = widget.data['startTime'] ?? "0:00";
    final end = widget.data['endTime'] ?? "0:00";

    startTime = TimeOfDay(
      hour: int.parse(start.split(":")[0]),
      minute: int.parse(start.split(":")[1]),
    );

    endTime = TimeOfDay(
      hour: int.parse(end.split(":")[0]),
      minute: int.parse(end.split(":")[1]),
    );

    isPublic = widget.data['isPublic'] ?? true;
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: startTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => startTime = picked);
    }
  }

  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: endTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => endTime = picked);
    }
  }

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
      final updateData = {
        'title': titleController.text.trim(),
        'location': locationController.text.trim(),
        'date': Timestamp.fromDate(selectedDate!),
        'startTime': "${startTime!.hour}:${startTime!.minute}",
        'endTime': "${endTime!.hour}:${endTime!.minute}",
        'isPublic': isPublic,
      };

      await FirestoreService().updateEvent(widget.eventId, updateData);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => error = "Failed to update event");
    }

    if (mounted) {
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Event")),
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

            Row(
              children: [
                Expanded(
                  child: Text(
                    startTime == null
                        ? "No start time"
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

            Row(
              children: [
                Expanded(
                  child: Text(
                    endTime == null ? "No end time" : endTime!.format(context),
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
                  : const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
