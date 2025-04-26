// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime _lastPeriodStartDate = DateTime.now().subtract(
    const Duration(days: 5),
  );
  int _cycleLength = 28;
  int _periodLength = 5;
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
    _loadSelections();
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
    }
    if (savedPeriodLength != null) {
      _periodLength = savedPeriodLength;
    }
  }

  Future<void> _saveSelections() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('day_selections', jsonEncode(_daySelections));
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
        title: const Text('Calendar'),
        backgroundColor: const Color(0xFFE75A7C),
      ),
      body: SingleChildScrollView(
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
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Color(0xFFE75A7C),
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Color(0xFFE75A7C),
                  ),
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Calendar is index 1
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
            // Already on calendar
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/mood');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/insights');
          }
        },
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
}
