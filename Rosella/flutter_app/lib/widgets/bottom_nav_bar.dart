import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
        BottomNavigationBarItem(icon: Icon(Icons.spa), label: 'Meditate'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Self Care'),
      ],
      selectedItemColor: Color(0xFFB388EB),
      unselectedItemColor: Colors.grey,
    );
  }
}
