// lib/screens/insights_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String _selectedTimeframe = 'Week';
  List<Map<String, dynamic>> _moodEntries = [];

  // Mood scores for calculation
  final Map<String, double> _moodScores = {
    'Amazing': 5.0,
    'Good': 4.0,
    'Neutral': 3.0,
    'Anxious': 2.0,
    'Angry': 1.0,
  };

  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  Future<void> _loadMoodData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString('mood_entries');

    if (entriesJson != null) {
      final List<dynamic> decoded = jsonDecode(entriesJson);
      setState(() {
        _moodEntries = List<Map<String, dynamic>>.from(
          decoded.map((item) => Map<String, dynamic>.from(item)),
        );
      });
    } else {
      // Include the same sample data that's in the MoodTrackerScreen
      setState(() {
        _moodEntries = [
          {'date': DateTime.now(), 'mood': 'Good'},
          {
            'date': DateTime.now().subtract(const Duration(days: 1)),
            'mood': 'Amazing',
          },
          {
            'date': DateTime.now().subtract(const Duration(days: 2)),
            'mood': 'Anxious',
          },
          {
            'date': DateTime.now().subtract(const Duration(days: 3)),
            'mood': 'Angry',
          },
        ];
      });
    }
  }

  String _getDateRangeText() {
    final now = DateTime.now();
    if (_selectedTimeframe == 'Week') {
      final start = now.subtract(Duration(days: now.weekday - 1));
      final end = start.add(const Duration(days: 6));
      return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
    } else if (_selectedTimeframe == 'Month') {
      return DateFormat('MMMM yyyy').format(now);
    } else {
      return DateFormat('yyyy').format(now);
    }
  }

  List<double> _calculateMoodScores() {
    final now = DateTime.now();
    List<double> scores = [];

    if (_selectedTimeframe == 'Week') {
      // 7 days, Mon-Sun
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      for (int i = 0; i < 7; i++) {
        final day = startOfWeek.add(Duration(days: i));
        final dayKey = DateFormat('yyyy-MM-dd').format(day);

        double sum = 0;
        int count = 0;
        for (var entry in _moodEntries) {
          final entryDate =
              entry['date'] is DateTime
                  ? entry['date'] as DateTime
                  : DateTime.parse(entry['date'].toString());
          if (DateFormat('yyyy-MM-dd').format(entryDate) == dayKey) {
            final mood = entry['mood'] as String;
            sum += _moodScores[mood] ?? 3.0;
            count++;
          }
        }
        scores.add(count > 0 ? sum / count : 0);
      }
    } else if (_selectedTimeframe == 'Month') {
      // 4 weeks in the month
      final currentMonth = now.month;
      final currentYear = now.year;
      for (int week = 0; week < 4; week++) {
        double sum = 0;
        int count = 0;
        for (var entry in _moodEntries) {
          final entryDate =
              entry['date'] is DateTime
                  ? entry['date'] as DateTime
                  : DateTime.parse(entry['date'].toString());
          if (entryDate.month == currentMonth &&
              entryDate.year == currentYear) {
            final weekOfMonth = (entryDate.day - 1) ~/ 7;
            if (weekOfMonth == week) {
              final mood = entry['mood'] as String;
              sum += _moodScores[mood] ?? 3.0;
              count++;
            }
          }
        }
        scores.add(count > 0 ? sum / count : 0);
      }
    } else {
      // Year: 12 months
      final year = now.year;
      for (int month = 1; month <= 12; month++) {
        double sum = 0;
        int count = 0;
        for (var entry in _moodEntries) {
          final entryDate =
              entry['date'] is DateTime
                  ? entry['date'] as DateTime
                  : DateTime.parse(entry['date'].toString());
          if (entryDate.year == year && entryDate.month == month) {
            final mood = entry['mood'] as String;
            sum += _moodScores[mood] ?? 3.0;
            count++;
          }
        }
        scores.add(count > 0 ? sum / count : 0);
      }
    }
    return scores;
  }

  @override
  Widget build(BuildContext context) {
    final moodScores = _calculateMoodScores();
    final List<String> labels = _getLabels();

    return Scaffold(
      backgroundColor: const Color(0xFFFCECF1),
      appBar: AppBar(
        title: const Text('Insights'),
        backgroundColor: const Color(0xFFE75A7C),
        actions: [IconButton(icon: const Icon(Icons.share), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeframe selector
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:
                      ['Week', 'Month', 'Year'].map((timeframe) {
                        final isSelected = _selectedTimeframe == timeframe;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTimeframe = timeframe;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color(0xFFE75A7C)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              timeframe,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: Text(
                  _getDateRangeText(),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                '${_selectedTimeframe}ly Average',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Custom Chart
              Container(
                height: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: CustomBarChart(scores: moodScores, labels: labels),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: const [
                            Text('😠', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        Column(
                          children: const [
                            Text('😰', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        Column(
                          children: const [
                            Text('😐', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        Column(
                          children: const [
                            Text('🙂', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        Column(
                          children: const [
                            Text('😂', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // Set to 3 for InsightsScreen
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
            // Already on InsightsScreen
          }
        },
      ),
    );
  }

  List<String> _getLabels() {
    if (_selectedTimeframe == 'Week') {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    } else if (_selectedTimeframe == 'Month') {
      return ['W1', 'W2', 'W3', 'W4'];
    } else {
      return ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    }
  }
}

class CustomBarChart extends StatelessWidget {
  final List<double> scores;
  final List<String> labels;

  const CustomBarChart({Key? key, required this.scores, required this.labels})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxHeight = constraints.maxHeight - 30; // Space for labels
        final double barWidth =
            (constraints.maxWidth - 20) / scores.length - 10;

        return Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(scores.length, (index) {
                  // Normalize height (5.0 is max score)
                  final double normalizedHeight =
                      scores[index] / 5.0 * maxHeight;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: barWidth,
                        height: normalizedHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE75A7C),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(labels.length, (index) {
                return SizedBox(
                  width: barWidth,
                  child: Text(
                    labels[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
