import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'event_details_screen.dart';
import 'create_event_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  String formatTime(String raw, BuildContext context) {
    final parts = raw.split(":");
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final t = TimeOfDay(hour: hour, minute: minute);
    return t.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Events"), centerTitle: true),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateEventScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          // ---------------- SEARCH BAR ----------------
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search events...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase());
              },
            ),
          ),

          // ---------------- EVENTS LIST ----------------
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .where('isPublic', isEqualTo: true)
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // ---------------- FILTERING ----------------
                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final title = (data['title'] ?? '').toString().toLowerCase();
                  final location = (data['location'] ?? '')
                      .toString()
                      .toLowerCase();
                  final desc = (data['description'] ?? '')
                      .toString()
                      .toLowerCase();

                  return title.contains(searchQuery) ||
                      location.contains(searchQuery) ||
                      desc.contains(searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No events found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final doc = filtered[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final eventId = doc.id;

                    final title = data['title'] ?? 'Untitled Event';
                    final location = data['location'] ?? 'No location';
                    final Timestamp? ts = data['date'];
                    final date = ts?.toDate();

                    final start = data['startTime'] ?? "0:00";
                    final end = data['endTime'] ?? "0:00";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              date != null
                                  ? "${date.month}/${date.day}/${date.year}"
                                  : "No date",
                            ),
                            Text(
                              "${formatTime(start, context)} – ${formatTime(end, context)}",
                            ),
                            const SizedBox(height: 4),
                            Text(location),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EventDetailsScreen(eventId: eventId),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
