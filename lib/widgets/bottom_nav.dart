import 'package:flutter/material.dart';
import '../screens/feed_screen.dart';
import '../screens/matches_screen.dart';
import '../screens/chat_list_screen.dart';
import '../screens/events_screen.dart';
import '../screens/profile_screen.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const FeedScreen();
        break;
      case 1:
        screen = const MatchesScreen();
        break;
      case 2:
        screen = const ChatListScreen();
        break;
      case 3:
        screen = const EventsScreen();
        break;
      case 4:
        screen = const ProfileScreen();
        break;
      default:
        screen = const FeedScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) => _navigate(context, i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Feed"),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Matches"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Messages"),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
