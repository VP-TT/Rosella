import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime _lastPeriodStartDate = DateTime.now().subtract(const Duration(days: 5));
  int _cycleLength = 28;
  int _periodLength = 5;
  DateTime? _nextPeriodDate;
  int _daysUntilNextPeriod = 0;
  int _currentCycleDay = 0;
  Map<String, List<String>> _daySelections = {};
  final TextEditingController _cycleLengthController = TextEditingController();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _cycleLengthController.text = _cycleLength.toString();
    _calculateCycleDates();
    _loadSelections();
    _loadUserData(); // Added to load profile data
  }

  // New method to load user data from Firestore
  Future<void> _loadUserData() async {
    try {
      _currentUser = _auth.currentUser;

      if (_currentUser != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>?;

            // Update cycle information from user profile
            if (_userData != null && _userData!.containsKey('cycleInfo')) {
              final cycleInfo = _userData!['cycleInfo'];

              // Update cycle length
              if (cycleInfo['averageCycleLength'] != null && cycleInfo['averageCycleLength'].isNotEmpty) {
                _cycleLength = int.tryParse(cycleInfo['averageCycleLength']) ?? _cycleLength;
                _cycleLengthController.text = _cycleLength.toString();
              }

              // Update period length
              if (cycleInfo['averagePeriodLength'] != null && cycleInfo['averagePeriodLength'].isNotEmpty) {
                _periodLength = int.tryParse(cycleInfo['averagePeriodLength']) ?? _periodLength;
              }

              // Update last period date
              if (cycleInfo['lastPeriod'] != null && cycleInfo['lastPeriod'].isNotEmpty) {
                try {
                  _lastPeriodStartDate = DateFormat('d MMMM yyyy').parse(cycleInfo['lastPeriod']);
                  _calculateCycleDates();
                } catch (e) {
                  print('Error parsing last period date: $e');
                }
              }
            }
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadSelections() async {
    final prefs = await SharedPreferences.getInstance();
    final String? selectionsJson = prefs.getString('day_selections');
    if (selectionsJson != null) {
      setState(() {
        final Map<String, dynamic> decoded = jsonDecode(selectionsJson);
        _daySelections = Map<String, List<String>>.from(
          decoded.map((key, value) => MapEntry(key, List<String>.from(value))),
        );
      });
    }

    // Also load saved period data
    final String? lastPeriodString = prefs.getString('last_period_start');
    final int? savedCycleLength = prefs.getInt('cycle_length');
    final int? savedPeriodLength = prefs.getInt('period_length');

    if (lastPeriodString != null) {
      _lastPeriodStartDate = DateTime.parse(lastPeriodString);
    }
    if (savedCycleLength != null) {
      _cycleLength = savedCycleLength;
      _cycleLengthController.text = _cycleLength.toString();
    }
    if (savedPeriodLength != null) {
      _periodLength = savedPeriodLength;
    }

    _calculateCycleDates();
  }

  Future<void> _savePeriodData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'last_period_start',
      _lastPeriodStartDate.toIso8601String(),
    );
    await prefs.setInt('cycle_length', _cycleLength);
    await prefs.setInt('period_length', _periodLength);
  }

  void _calculateCycleDates() {
    // Calculate next period date
    _nextPeriodDate = _lastPeriodStartDate.add(Duration(days: _cycleLength));

    // Calculate days until next period
    _daysUntilNextPeriod = _nextPeriodDate!.difference(DateTime.now()).inDays;
    if (_daysUntilNextPeriod < 0) {
      // If next period date is in the past, recalculate based on cycle length
      final cycles = (DateTime.now().difference(_lastPeriodStartDate).inDays / _cycleLength).ceil();
      _nextPeriodDate = _lastPeriodStartDate.add(Duration(days: cycles * _cycleLength));
      _daysUntilNextPeriod = _nextPeriodDate!.difference(DateTime.now()).inDays;
    }

    // Calculate current cycle day
    _currentCycleDay = DateTime.now().difference(_lastPeriodStartDate).inDays % _cycleLength + 1;
  }

  bool _isPeriodDay(DateTime day) {
    // Check if the day is within the current period
    for (int i = 0; i < _periodLength; i++) {
      final periodDay = _lastPeriodStartDate.add(Duration(days: i));
      if (isSameDay(day, periodDay)) return true;
    }

    // Check future periods
    DateTime periodStart = _lastPeriodStartDate;
    while (periodStart.isBefore(day.add(const Duration(days: 1)))) {
      periodStart = periodStart.add(Duration(days: _cycleLength));
      for (int i = 0; i < _periodLength; i++) {
        final periodDay = periodStart.add(Duration(days: i));
        if (isSameDay(day, periodDay)) return true;
      }
    }

    return false;
  }

  bool _isOvulationDay(DateTime day) {
    // Ovulation typically occurs 14 days before the next period
    DateTime periodStart = _lastPeriodStartDate;
    while (periodStart.isBefore(day.add(const Duration(days: 30)))) {
      final ovulationDay = periodStart.add(Duration(days: _cycleLength - 14));
      // Consider a 3-day ovulation window
      for (int i = -1; i <= 1; i++) {
        if (isSameDay(day, ovulationDay.add(Duration(days: i)))) return true;
      }
      periodStart = periodStart.add(Duration(days: _cycleLength));
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCECF1),
      appBar: AppBar(
        title: const Text('Rosella'),
        backgroundColor: const Color(0xFFE75A7C),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile').then((_) {
                // Reload user data when returning from profile screen
                _loadUserData();
              });
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
              _buildCycleTracker(),
              const SizedBox(height: 24),
              _buildFeatureGrid(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0, // Home is selected
        selectedItemColor: const Color(0xFFE75A7C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.mood), label: 'Mood'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Insights'),
        ],
        onTap: (index) {
          if (index == 0) {
            // Already on home
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

  Widget _buildCycleTracker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cycle Tracker',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Days Until Next Period',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_daysUntilNextPeriod days',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE75A7C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Next period: ${DateFormat('MMM d, yyyy').format(_nextPeriodDate!)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECF1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Day',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '$_currentCycleDay',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE75A7C),
                        ),
                      ),
                      Text(
                        'of $_cycleLength',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Cycle Length:'),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _cycleLengthController,
                  keyboardType: TextInputType.number,
                  readOnly: true, // Make it read-only
                  enabled: false, // Disable the field
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE75A7C)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFE75A7C),
                        width: 2,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Text('days'),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _lastPeriodStartDate = DateTime.now();
                    _calculateCycleDates();
                    _savePeriodData();
                  });

                  // Update Firestore if user is logged in
                  if (_currentUser != null) {
                    _firestore.collection('users').doc(_currentUser!.uid).update({
                      'cycleInfo.lastPeriod': DateFormat('d MMMM yyyy').format(DateTime.now()),
                    }).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Period logged successfully')),
                      );
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error logging period: $error')),
                      );
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE75A7C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('Log Period Today'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Features',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildFeatureCard(
              'Symptom Mapping',
              Icons.thermostat,
              const Color(0xFFFFD6E0),
              '/symptom',
            ),
            _buildFeatureCard(
              'Ultrasound Check',
              Icons.water_drop,
              const Color(0xFFFFECB3),
              '/ultrasound',
            ),
            _buildFeatureCard(
              'Mood Tracker',
              Icons.mood,
              const Color(0xFFD1F5FF),
              '/mood',
            ),
            _buildFeatureCard(
              'Nearest Clinics',
              Icons.medical_services,
              const Color(0xFFE0F7FA),
              '/nearby',
            ),
            _buildFeatureCard(
              'Exercise',
              Icons.fitness_center,
              const Color(0xFFE8F5E9),
              '/exercises',
            ),
            _buildFeatureCard(
              'Sleep Tracker',
              Icons.nightlight,
              const Color(0xFFE1BEE7),
              '/sleep_tracker',
            ),
            _buildFeatureCard(
              'Notes',
              Icons.note_alt,
              const Color(0xFFFFCCBC),
              '/notes',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black87),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
