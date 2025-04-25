// lib/screens/home_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/cycle_tracker_widget.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/feature_card.dart';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime _lastPeriodStartDate = DateTime.now().subtract(
    const Duration(days: 5),
  );
  int _cycleLength = 28;
  int _periodLength = 5;
  int _currentDay = 2;
  late DateTime _nextPeriodStart;
  int _daysUntilNextPeriod = 24;
  final TextEditingController _cycleLengthController = TextEditingController();
  Map<String, List<String>> _daySelections = {};

  // Symptoms options for tracking
  final List<Map<String, dynamic>> _symptoms = [
    {'name': 'Cramps', 'icon': Icons.sick, 'selected': false},
    {'name': 'Headache', 'icon': Icons.healing, 'selected': false},
    {'name': 'Mood Swings', 'icon': Icons.mood_bad, 'selected': false},
    {'name': 'Fatigue', 'icon': Icons.battery_alert, 'selected': false},
    {'name': 'Bloating', 'icon': Icons.water, 'selected': false},
    {
      'name': 'Tender Breasts',
      'icon': Icons.favorite_border,
      'selected': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _cycleLengthController.text = _cycleLength.toString();
    _calculateCycleDates();
    _loadSelections();
  }

  void _calculateCycleDates() {
    _nextPeriodStart = _lastPeriodStartDate.add(Duration(days: _cycleLength));
    _daysUntilNextPeriod = _daysBetween(DateTime.now(), _nextPeriodStart);
    _currentDay = _daysBetween(_lastPeriodStartDate, DateTime.now()) + 1;
    if (_currentDay > _cycleLength) {
      _currentDay = _currentDay % _cycleLength;
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

  Future<void> _saveSelections() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('day_selections', jsonEncode(_daySelections));
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

  int _daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
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

  void _updateCycleLength(String value) {
    int? newLength = int.tryParse(value);
    if (newLength != null && newLength >= 21 && newLength <= 35) {
      setState(() {
        _cycleLength = newLength;
        _calculateCycleDates();
        _savePeriodData();
      });
    }
  }

  void _logPeriodToday() {
    setState(() {
      _lastPeriodStartDate = DateTime.now();
      _calculateCycleDates();
      _savePeriodData();
    });
  }

  void _selectSymptom(int index) {
    setState(() {
      _symptoms[index]['selected'] = !_symptoms[index]['selected'];

      if (_selectedDay != null) {
        final dayKey = _selectedDay.toString().split(' ')[0];
        _daySelections[dayKey] =
            _symptoms
                .where((symptom) => symptom['selected'])
                .map((symptom) => symptom['name'] as String)
                .toList();
        _saveSelections();
      }
    });
  }

  void _loadDaySelections(DateTime day) {
    final dayKey = day.toString().split(' ')[0];
    final selections = _daySelections[dayKey] ?? [];

    // Reset all symptoms
    for (var symptom in _symptoms) {
      symptom['selected'] = false;
    }

    // Set selected symptoms for this day
    for (var symptomName in selections) {
      final index = _symptoms.indexWhere((s) => s['name'] == symptomName);
      if (index != -1) {
        _symptoms[index]['selected'] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCECF1),
      appBar: AppBar(
        title: const Text('Period Tracker'),
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
      body: _getScreenForIndex(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Important for 4+ items
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFE75A7C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.mood), label: 'Mood'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Insights'),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 0) {
            // Stay on home screen
          } else if (index == 1) {
            // Show calendar tab
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/mood');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/insights');
          }
        },
      ),


    );
  }

  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildCalendar();
      case 2:
        return _buildHealthContent();
      case 3:
        return _buildInsightsContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cycle Tracker
            _buildCycleTracker(),

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
              children: [
                _buildFeatureCard(
                  'Mood Tracker',
                  Icons.mood,
                  const Color(0xFFFFD6E0),
                ),
                _buildFeatureCard(
                  'Period Flow',
                  Icons.water_drop,
                  const Color(0xFFFFECB3),
                ),
                _buildFeatureCard(
                  'Temperature',
                  Icons.thermostat,
                  const Color(0xFFD1F5FF),
                ),
                _buildFeatureCard(
                  'Symptoms',
                  Icons.medical_services,
                  const Color(0xFFE0F7FA),
                ),
                _buildFeatureCard(
                  'Weight Log',
                  Icons.fitness_center,
                  const Color(0xFFE8F5E9),
                ),
                _buildFeatureCard(
                  'Sleep Tracker',
                  Icons.nightlight,
                  const Color(0xFFE1BEE7),
                ),
                _buildFeatureCard(
                  'Notes',
                  Icons.note_alt,
                  const Color(0xFFFFCCBC),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthContent() {
    return const Center(child: Text('Health Tracking Coming Soon!'));
  }

  Widget _buildInsightsContent() {
    return const Center(child: Text('Insights Coming Soon!'));
  }

  Widget _buildCycleTracker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        children: [
          const Text('Current Cycle', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),

          // Day circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: _currentDay / _cycleLength,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFFCECF1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFE75A7C),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Day', style: TextStyle(color: Color(0xFFE75A7C))),
                  Text(
                    '$_currentDay',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE75A7C),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Info boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Days until next period',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '$_daysUntilNextPeriod days',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Next Period',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        DateFormat('MM/dd/yyyy').format(_nextPeriodStart),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Log period button
          ElevatedButton(
            onPressed: _logPeriodToday,
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

          const SizedBox(height: 16),

          // Cycle length input
          Row(
            children: [
              const Text('Cycle Length:', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _cycleLengthController,
                  keyboardType: TextInputType.number,
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
                  ),
                  onChanged: _updateCycleLength,
                ),
              ),
              const SizedBox(width: 8),
              const Text('days', style: TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
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
            padding: const EdgeInsets.all(16),
            child: TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2026, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _loadDaySelections(selectedDay);
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: const Color(0xFFE75A7C).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFFE75A7C),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Color(0xFFE75A7C),
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE75A7C),
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFFE75A7C)),
                rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFFE75A7C)),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  // Check if this day is in period
                  if (_isPeriodDay(day)) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE75A7C),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  // Check if this day is ovulation
                  else if (_isOvulationDay(day)) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD6E0),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),

          // Add this section to display the symptom tracker when a day is selected
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: _buildSymptomTracker(),
            ),
        ],
      ),
    );
  }


  Widget _buildSymptomTracker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Symptoms for ${DateFormat('MMM d, yyyy').format(_selectedDay!)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(_symptoms.length, (index) {
              return GestureDetector(
                onTap: () => _selectSymptom(index),
                child: Chip(
                  backgroundColor:
                      _symptoms[index]['selected']
                          ? const Color(0xFFE75A7C)
                          : const Color(0xFFF5F5F5),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _symptoms[index]['icon'],
                        size: 16,
                        color:
                            _symptoms[index]['selected']
                                ? Colors.white
                                : Colors.black,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _symptoms[index]['name'],
                        style: TextStyle(
                          color:
                              _symptoms[index]['selected']
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveSelections,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE75A7C),
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Save Symptoms',
              style: TextStyle(color: Colors.white),
            ),

          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, Color color) {
    return Container(
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
    );
  }
}
