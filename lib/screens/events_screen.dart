import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/event_model.dart';
import '../services/auth_service.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upcoming Events")),
      body: StreamBuilder<List<EventModel>>(
        stream: FirestoreService().getPublicEvents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, i) {
              final e = events[i];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(e.date.toDate().toString()),
                      Text(e.location),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final user =
                              await AuthService().authStateChanges.first;
                          await FirestoreService().rsvpEvent(
                            e.eventId,
                            user!.uid,
                            "going",
                          );
                        },
                        child: const Text("RSVP"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
