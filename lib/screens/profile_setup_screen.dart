import 'package:flutter/material.dart';

class ProfileSetupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile Setup")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: "Major")),
            TextField(decoration: InputDecoration(labelText: "Year")),
            TextField(decoration: InputDecoration(labelText: "Courses")),
            TextField(decoration: InputDecoration(labelText: "Interests")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text("Finish Setup")),
          ],
        ),
      ),
    );
  }
}
