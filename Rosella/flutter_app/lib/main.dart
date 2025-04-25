// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/profile_screen.dart';
import 'package:flutter_app/screens/user_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/user_form_screen.dart';
import 'screens/personalized_welcome_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Period Tracker',
      theme: ThemeData(
        primaryColor: const Color(0xFFE75A7C),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFFE75A7C),
          secondary: const Color(0xFFFFD6E0),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          displayMedium: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          bodyLarge: TextStyle(fontSize: 16.0, color: Color(0xFF666666)),
          bodyMedium: TextStyle(fontSize: 14.0, color: Color(0xFF666666)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/user_form': (context) => const UserFormScreen(),
        '/personalized_welcome': (context) => const PersonalizedWelcomeScreen(),
        '/home':
            (context) => const HomeScreen(), // You'll need to implement this
        '/profile': (context) => ProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
