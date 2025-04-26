// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_app/screens/calendar_screen.dart';
import 'package:flutter_app/screens/exercises_screen.dart';
import 'package:flutter_app/screens/insights_screen.dart';
import 'package:flutter_app/screens/mood_tracker_screen.dart';
import 'package:flutter_app/screens/nearby_hospitals_screen.dart';
import 'package:flutter_app/screens/profile_screen.dart';
// import 'package:flutter_app/screens/symptom_tracker.dart';
import 'package:flutter_app/screens/symptom_home_screen.dart';
import 'package:flutter_app/screens/exercises_screen.dart';

import 'package:flutter_app/screens/symptoms_screen.dart';
import 'package:flutter_app/screens/ultrasound_screen.dart';
// import 'package:flutter_app/screens/profile_screen.dart';
import 'package:flutter_app/screens/user_auth_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/personalized_welcome_screen.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        '/': (context) => SplashPage(),
        '/auth': (context) => const AuthScreen(),
        '/personalized_welcome': (context) => const PersonalizedWelcomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/mood': (context) => const MoodTrackerScreen(),
        '/insights': (context) => const InsightsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/symptom': (context) => const HomeScreen1(),
        '/exercises':(context)=> PCOSExerciseCompanion(),
        '/nearby':(context)=> NearbyHospitalsScreen(),
        '/ultrasound':(context)=> UltrasoundUploadScreen(),


      },
      debugShowCheckedModeBanner: false,
    );
  }
}
