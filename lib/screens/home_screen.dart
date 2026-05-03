import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'feed_screen.dart';
import 'matches_screen.dart';
import 'chat_list_screen.dart';
import 'events_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  bool _seeding = false;

  final screens = const [
    FeedScreen(),
    MatchesScreen(),
    ChatListScreen(),
    EventsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QuadConnect"),
        actions: [
          IconButton(
            icon: _seeding
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload),
            onPressed: _seeding ? null : _handleSeed,
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Matches"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Future<void> _handleSeed() async {
    setState(() => _seeding = true);
    try {
      await _seedData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Seed data uploaded")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  Future<void> _seedData() async {
    final db = FirebaseFirestore.instance;

    // USERS
    await db.collection('users').doc('user_1').set({
      'name': 'Alex Johnson',
      'major': 'Computer Science',
      'year': 'Sophomore',
      'courses': ['CSC3210', 'CSC4320'],
      'interests': ['AI', 'Gaming', 'Hackathons'],
      'availability': ['Mon 6-8', 'Wed 7-9'],
      'bio': 'Love AI and hackathons!',
      'photoUrl': '',
      'fcmToken': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await db.collection('users').doc('user_2').set({
      'name': 'Jordan Lee',
      'major': 'Information Systems',
      'year': 'Junior',
      'courses': ['CSC3210', 'BUS2200'],
      'interests': ['Startups', 'Study Groups'],
      'availability': ['Tue 5-7', 'Thu 6-8'],
      'bio': 'Building the next big thing.',
      'photoUrl': '',
      'fcmToken': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await db.collection('users').doc('user_3').set({
      'name': 'Taylor Smith',
      'major': 'Computer Science',
      'year': 'Senior',
      'courses': ['CSC4320', 'CSC4350'],
      'interests': ['AI', 'Research', 'Coding'],
      'availability': ['Mon 8-10', 'Fri 3-5'],
      'bio': 'Senior researcher and coder.',
      'photoUrl': '',
      'fcmToken': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await db.collection('users').doc('user_4').set({
      'name': 'Morgan Brown',
      'major': 'Data Science',
      'year': 'Sophomore',
      'courses': ['CSC3210', 'MATH2400'],
      'interests': ['Data', 'Fitness'],
      'availability': ['Wed 6-8', 'Sat 10-12'],
      'bio': 'Data nerd who loves the gym.',
      'photoUrl': '',
      'fcmToken': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await db.collection('users').doc('user_5').set({
      'name': 'Casey Wilson',
      'major': 'Information Systems',
      'year': 'Freshman',
      'courses': ['CSC1301', 'ENG1100'],
      'interests': ['Music', 'Gaming'],
      'availability': ['Mon 4-6', 'Thu 7-9'],
      'bio': 'Fresh on campus, ready to connect!',
      'photoUrl': '',
      'fcmToken': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // POSTS
    await db.collection('posts').doc('post_1').set({
      'userName': 'Alex Johnson',
      'content': 'Anyone down for a study group?',
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 3,
    });

    await db.collection('posts').doc('post_2').set({
      'userName': 'Jordan Lee',
      'content': 'Coding all night 💻',
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 5,
    });

    await db.collection('posts').doc('post_3').set({
      'userName': 'Taylor Smith',
      'content': 'Exam prep grind starts now',
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 2,
    });

    await db.collection('posts').doc('post_4').set({
      'userName': 'Morgan Brown',
      'content': 'Data structures finally clicking!',
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 7,
    });

    await db.collection('posts').doc('post_5').set({
      'userName': 'Casey Wilson',
      'content': 'First week on campus vibes 🔥',
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 4,
    });

    await db.collection('posts').doc('post_6').set({
      'userName': 'Alex Johnson',
      'content': 'Looking for hackathon teammates',
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 6,
    });

    // EVENTS
    await db.collection('events').doc('event_1').set({
      'title': 'CS Study Night',
      'description': 'Group study for CSC3210',
      'date': Timestamp.fromDate(DateTime(2026, 5, 3)),
      'startTime': '18:00',
      'endTime': '20:00',
      'location': 'Library Room 201',
      'isPublic': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await db.collection('events').doc('event_2').set({
      'title': 'Campus Mixer',
      'description': 'Meet new students',
      'date': Timestamp.fromDate(DateTime(2026, 5, 5)),
      'startTime': '17:00',
      'endTime': '19:00',
      'location': 'Student Center',
      'isPublic': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await db.collection('events').doc('event_3').set({
      'title': 'Hackathon Kickoff',
      'description': 'Start building projects',
      'date': Timestamp.fromDate(DateTime(2026, 5, 7)),
      'startTime': '9:00',
      'endTime': '17:00',
      'location': 'Engineering Hall',
      'isPublic': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await db.collection('events').doc('event_4').set({
      'title': 'Career Workshop',
      'description': 'Resume + interview prep',
      'date': Timestamp.fromDate(DateTime(2026, 5, 9)),
      'startTime': '13:00',
      'endTime': '15:00',
      'location': 'Business Building',
      'isPublic': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await db.collection('events').doc('event_5').set({
      'title': 'Game Night',
      'description': 'Relax + games',
      'date': Timestamp.fromDate(DateTime(2026, 5, 10)),
      'startTime': '19:00',
      'endTime': '21:00',
      'location': 'Dorm Lounge',
      'isPublic': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
