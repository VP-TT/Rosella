// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/cycle_tracker_widget.dart';
import '../widgets/cycle_tracker_widget.dart';
import '../widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCECF1),
      appBar: AppBar(
        title: const Text('November 2021'),
        backgroundColor: const Color(0xFFE75A7C),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar Week View
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDayColumn('S', '22', false),
                    _buildDayColumn('M', '23', false),
                    _buildDayColumn('T', '24', false),
                    _buildDayColumn('W', '25', false),
                    _buildDayColumn('T', '26', true),
                    _buildDayColumn('F', '27', false),
                    _buildDayColumn('S', '28', false),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Cycle Tracker
              const CycleTrackerWidget(currentDay: 2, cycleLength: 28),

              const SizedBox(height: 24),

              // Features Grid
              const Text(
                'Track Your Health',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: const [
                  FeatureCard(
                    icon: Icons.mood,
                    title: 'Mood Tracker',
                    color: Color(0xFFFFD6E0),
                  ),
                  FeatureCard(
                    icon: Icons.water_drop,
                    title: 'Period Flow',
                    color: Color(0xFFFFECB3),
                  ),
                  FeatureCard(
                    icon: Icons.thermostat,
                    title: 'Temperature',
                    color: Color(0xFFD1F5FF),
                  ),
                  FeatureCard(
                    icon: Icons.medical_services,
                    title: 'Symptoms',
                    color: Color(0xFFE0F7FA),
                  ),
                  FeatureCard(
                    icon: Icons.fitness_center,
                    title: 'Weight Log',
                    color: Color(0xFFE8F5E9),
                  ),
                  FeatureCard(
                    icon: Icons.nightlight,
                    title: 'Sleep Tracker',
                    color: Color(0xFFE1BEE7),
                  ),
                  FeatureCard(
                    icon: Icons.note_alt,
                    title: 'Notes',
                    color: Color(0xFFFFCCBC),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFFE75A7C),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Health'),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Insights',
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(String day, String date, bool isActive) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            color: isActive ? const Color(0xFFE75A7C) : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFE75A7C) : Colors.transparent,
          ),
          child: Center(
            child: Text(
              date,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
