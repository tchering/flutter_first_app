import 'package:flutter/material.dart';
import 'home_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,  // Explicitly set white background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,  // Add background color
              child: Icon(Icons.person, size: 50, color: Colors.white),  // Add icon color
            ),
            SizedBox(height: 20),
            Text(
              'User Name', 
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,  // Explicitly set text color
              )
            ),
            Text(
              'user@example.com', 
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,  // Explicitly set text color
              )
            ),
          ],
        ),
      ),
    );
  }
}
