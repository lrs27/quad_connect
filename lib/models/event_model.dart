import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String title;
  final String description;
  final Timestamp date;
  final String location;
  final String bannerUrl;
  final String createdBy;

  EventModel({
    required this.eventId,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.bannerUrl,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'title': title,
      'description': description,
      'date': date,
      'location': location,
      'bannerUrl': bannerUrl,
      'createdBy': createdBy,
    };
  }

  factory EventModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      eventId: data['eventId'],
      title: data['title'],
      description: data['description'],
      date: data['date'],
      location: data['location'],
      bannerUrl: data['bannerUrl'],
      createdBy: data['createdBy'],
    );
  }
}
