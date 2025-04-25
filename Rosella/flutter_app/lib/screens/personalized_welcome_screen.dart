// lib/screens/personalized_welcome_screen.dart
import 'package:flutter/material.dart';

class PersonalizedWelcomeScreen extends StatelessWidget {
  const PersonalizedWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final username = ModalRoute.of(context)!.settings.arguments as String;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF5E9), // Background color
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Menstruation Tracker',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hi, $username!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 30),
                Image.asset(
                  "assets/images/welcome_illustration.png",
                  height: 300,
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE75A7C),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
