// lib/screens/period_flow_screen.dart
import 'package:flutter/material.dart';

class PeriodFlowScreen extends StatefulWidget {
  const PeriodFlowScreen({Key? key}) : super(key: key);

  @override
  State<PeriodFlowScreen> createState() => _PeriodFlowScreenState();
}

class _PeriodFlowScreenState extends State<PeriodFlowScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCECF1),
      appBar: AppBar(
        title: const Text('Period Flow'),
        backgroundColor: const Color(0xFFE75A7C),
      ),
      body: Center(child: Text('Period Flow Tracking Coming Soon!')),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0, // Home is selected
        selectedItemColor: const Color(0xFFE75A7C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.mood), label: 'Mood'),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Insights',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/calendar');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/mood');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/insights');
          }
        },
      ),
    );
  }
}
