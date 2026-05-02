import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'edit_event_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        if (data == null) {
          return const Scaffold(body: Center(child: Text("Event not found")));
        }

        final title = data['title'] ?? "Untitled Event";
        final currentUid = FirebaseAuth.instance.currentUser!.uid;
        final createdBy = data['createdBy'];
        final location = data['location'] ?? "No location";
        final Timestamp? ts = data['date'];
        final date = ts?.toDate();

        final start = data['startTime'] ?? "0:00";
        final end = data['endTime'] ?? "0:00";

        final goingCount = data['goingCount'] ?? 0;

        final rsvpRef = FirebaseFirestore.instance
            .collection("events")
            .doc(eventId)
            .collection("rsvps")
            .doc(currentUid);

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              if (createdBy == currentUid) ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditEventScreen(eventId: eventId, data: data),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Delete Event"),
                        content: const Text(
                          "Are you sure you want to delete this event?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await FirestoreService().deleteEvent(eventId);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
              ],
            ],
          ),

          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  date != null
                      ? "${date.month}/${date.day}/${date.year}"
                      : "No date",
                ),

                const SizedBox(height: 8),
                Text("$start – $end"),

                const SizedBox(height: 8),
                Text(location),

                const SizedBox(height: 16),

                //  RSVP COUNT
                Text(
                  "$goingCount going",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 206, 185, 242),
                  ),
                ),

                const SizedBox(height: 20),

                // RSVP / CANCEL RSVP BUTTON
                FutureBuilder<DocumentSnapshot>(
                  future: rsvpRef.get(),
                  builder: (context, rsvpSnap) {
                    if (!rsvpSnap.hasData) {
                      return const SizedBox(
                        height: 48,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final hasRsvped = rsvpSnap.data!.exists;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final uid = FirebaseAuth.instance.currentUser!.uid;

                            if (hasRsvped) {
                              // CANCEL RSVP
                              await FirestoreService().cancelRsvp(eventId, uid);
                            } else {
                              // ADD RSVP
                              final me = await FirestoreService().getUser(uid);
                              final name = me?['name'] ?? "Unknown";

                              await FirestoreService().rsvpToEvent(
                                eventId,
                                uid,
                                name,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasRsvped
                                ? Colors.red
                                : const Color.fromARGB(255, 227, 217, 246),
                          ),
                          child: Text(
                            hasRsvped ? "Cancel RSVP" : "RSVP",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        if (hasRsvped)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              "You are going ✓",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
