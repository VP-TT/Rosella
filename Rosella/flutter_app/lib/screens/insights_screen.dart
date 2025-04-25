// lib/screens/insights_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'mood_tracker_screen.dart';


class InsightsScreen extends StatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String _selectedTimeframe = 'Week';
  Map<String, List<String>> _moodActivities = {};
  Map<String, int> _activityCounts = {};
  List<double> _weeklyMoodScores = [4, 3.5, 4.5, 3, 2.5, 4, 5];

  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  Future<void> _loadMoodData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? activitiesJson = prefs.getString('mood_activities');

    if (activitiesJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(activitiesJson);
      setState(() {
        _moodActivities = Map<String, List<String>>.from(
          decoded.map((key, value) => MapEntry(key, List<String>.from(value))),
        );
      });

      _calculateActivityCounts();
    }
  }

  void _calculateActivityCounts() {
    Map<String, int> counts = {};

    _moodActivities.forEach((date, activities) {
      for (var activity in activities) {
        if (counts.containsKey(activity)) {
          counts[activity] = counts[activity]! + 1;
        } else {
          counts[activity] = 1;
        }
      }
    });

    // Sort by count
    var sortedEntries =
        counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    Map<String, int> sortedCounts = {};
    for (var entry in sortedEntries) {
      sortedCounts[entry.key] = entry.value;
    }

    setState(() {
      _activityCounts = sortedCounts;
    });
  }

  @override
  Widget build(BuildContext context) {
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

              // Date range
              Center(
                child: Text(
                  'May 1, 2025 - May 7, 2025',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),

              const SizedBox(height: 24),

              // Weekly Average
              const Text(
                'Weekly Average',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // Chart
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
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 5,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = [
                                    'Sun',
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                  ];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      days[value.toInt()],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                },
                                reservedSize: 30,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(7, (index) {
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: _weeklyMoodScores[index],
                                  color: const Color(0xFFE75A7C),
                                  width: 20,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        return Column(
                          children: [
                            Text('😊', style: TextStyle(fontSize: 20)),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Top Weekly Activities
              const Text(
                'Top Weekly Activities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // Activity bars
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children:
                      _activityCounts.entries.take(6).map((entry) {
                        final activity = entry.key;
                        final count = entry.value;
                        final percentage =
                            (count / _moodActivities.length * 100).round();

                        Color barColor;
                        switch (activity.toLowerCase()) {
                          case 'family':
                            barColor = Colors.green.shade200;
                            break;
                          case 'work':
                            barColor = Colors.blue.shade200;
                            break;
                          case 'sleep':
                            barColor = Colors.purple.shade200;
                            break;
                          case 'exercise':
                            barColor = Colors.orange.shade200;
                            break;
                          case 'yoga':
                            barColor = Colors.pink.shade200;
                            break;
                          case 'sports':
                            barColor = Colors.teal.shade200;
                            break;
                          default:
                            barColor = Colors.grey.shade200;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              SizedBox(width: 80, child: Text(activity)),
                              Expanded(
                                child: Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                150) *
                                            percentage /
                                            100,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: barColor,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  '$percentage%',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      // In your MoodTrackerScreen and InsightsScreen
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // Set to 2 for MoodScreen or 3 for InsightsScreen
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
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            // Handle Calendar tab - either navigate or stay on home with calendar tab
            Navigator.pushReplacementNamed(context, '/home');
            // You might need to pass a parameter to show the calendar tab
          } else if (index == 2 && !(this is MoodTrackerScreen)) {
            Navigator.pushReplacementNamed(context, '/mood');
          } else if (index == 3 && !(this is InsightsScreen)) {
            Navigator.pushReplacementNamed(context, '/insights');
          }
        },
      ),

    );
  }
}
