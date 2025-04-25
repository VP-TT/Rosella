// lib/screens/mood_tracker_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'insights_screen.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({Key? key}) : super(key: key);

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen>
    with SingleTickerProviderStateMixin {
  int _streak = 0;
  List<Map<String, dynamic>> _moodEntries = [];
  List<String> _activities = [
    'Work',
    'Family',
    'Sleep',
    'Exercise',
    'Yoga',
    'Sports',
  ];
  Map<String, List<String>> _selectedActivities = {};
  String _currentMood = '';

  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  Future<void> _loadMoodData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString('mood_entries');
    final String? activitiesJson = prefs.getString('mood_activities');
    final int streak = prefs.getInt('mood_streak') ?? 0;

    if (entriesJson != null) {
      final List<dynamic> decoded = jsonDecode(entriesJson);
      setState(() {
        _moodEntries = List<Map<String, dynamic>>.from(
          decoded.map((item) => Map<String, dynamic>.from(item)),
        );
      });
    } else {
      // Initialize with some sample data
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

    if (activitiesJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(activitiesJson);
      setState(() {
        _selectedActivities = Map<String, List<String>>.from(
          decoded.map((key, value) => MapEntry(key, List<String>.from(value))),
        );
      });
    }

    setState(() {
      _streak = streak;
    });
  }

  Future<void> _saveMoodData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mood_entries', jsonEncode(_moodEntries));
    await prefs.setString('mood_activities', jsonEncode(_selectedActivities));
    await prefs.setInt('mood_streak', _streak);
  }

  void _addMood(String mood) {
    setState(() {
      _currentMood = mood;
    });
  }

  void _toggleActivity(String activity) {
    final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    setState(() {
      if (_selectedActivities.containsKey(dateKey)) {
        if (_selectedActivities[dateKey]!.contains(activity)) {
          _selectedActivities[dateKey]!.remove(activity);
        } else {
          _selectedActivities[dateKey]!.add(activity);
        }
      } else {
        _selectedActivities[dateKey] = [activity];
      }
    });

    _saveMoodData();
  }

  String _getFormattedDate(DateTime date) {
    return '${date.day}\n${DateFormat('E').format(date).substring(0, 3)}';
  }

  Widget _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'amazing':
        return const Text('😂', style: TextStyle(fontSize: 40));
      case 'good':
        return const Text('🙂', style: TextStyle(fontSize: 40));
      case 'anxious':
        return const Text('😰', style: TextStyle(fontSize: 40));
      case 'angry':
        return const Text('😠', style: TextStyle(fontSize: 40));
      default:
        return const Text('😐', style: TextStyle(fontSize: 40));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCECF1),
      appBar: AppBar(
        title: const Text('Mood'),
        backgroundColor: const Color(0xFFE75A7C),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search Entries',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Streak
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F7FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Color(0xFF26A69A),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_streak Day Streak',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.calendar_month,
                      color: Color(0xFFE75A7C),
                    ),
                    label: const Text(
                      'View Calendar',
                      style: TextStyle(color: Color(0xFFE75A7C)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Week view
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    final date = DateTime.now().subtract(
                      Duration(days: 6 - index),
                    );
                    final isToday = index == 6;
                    return Column(
                      children: [
                        Text(
                          DateFormat('E').format(date).substring(0, 3),
                          style: TextStyle(
                            color:
                                isToday ? const Color(0xFFE75A7C) : Colors.grey,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isToday
                                    ? const Color(0xFFE75A7C)
                                    : Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(
                                color: isToday ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('😊', style: TextStyle(fontSize: 20)),
                      ],
                    );
                  }),
                ),
              ),

              const SizedBox(height: 24),

              // Mood Entries
              const Text(
                'Mood Entries',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // Mood entry cards
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _moodEntries.length,
                itemBuilder: (context, index) {
                  final entry = _moodEntries[index];
                  final date =
                      entry['date'] is DateTime
                          ? entry['date'] as DateTime
                          : DateTime.parse(entry['date'].toString());
                  final mood = entry['mood'] as String;
                  final dateKey = DateFormat('yyyy-MM-dd').format(date);
                  final activities = _selectedActivities[dateKey] ?? [];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date
                          Column(
                            children: [
                              Text(
                                date.day.toString(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateFormat('E').format(date).substring(0, 3),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          // Mood details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mood,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children:
                                      activities.map((activity) {
                                        Color chipColor;
                                        switch (activity.toLowerCase()) {
                                          case 'work':
                                            chipColor = Colors.blue.shade100;
                                            break;
                                          case 'family':
                                            chipColor = Colors.green.shade100;
                                            break;
                                          case 'sleep':
                                            chipColor = Colors.purple.shade100;
                                            break;
                                          case 'exercise':
                                            chipColor = Colors.orange.shade100;
                                            break;
                                          default:
                                            chipColor = Colors.grey.shade100;
                                        }

                                        return Chip(
                                          label: Text(activity),
                                          backgroundColor: chipColor,
                                          labelStyle: const TextStyle(
                                            fontSize: 12,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                        );
                                      }).toList(),
                                ),
                              ],
                            ),
                          ),
                          // Emoji
                          _getMoodEmoji(mood),
                        ],
                      ),
                    ),
                  );
                },
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE75A7C),
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder:
                (context) => AddMoodBottomSheet(
                  onMoodAdded: (mood, activities) {
                    setState(() {
                      _moodEntries.insert(0, {
                        'date': DateTime.now(),
                        'mood': mood,
                      });

                      final dateKey = DateFormat(
                        'yyyy-MM-dd',
                      ).format(DateTime.now());
                      _selectedActivities[dateKey] = activities;

                      // Update streak
                      final yesterday = DateTime.now().subtract(
                        const Duration(days: 1),
                      );
                      final yesterdayKey = DateFormat(
                        'yyyy-MM-dd',
                      ).format(yesterday);

                      if (_selectedActivities.containsKey(yesterdayKey)) {
                        _streak++;
                      } else {
                        _streak = 1;
                      }
                    });
                    _saveMoodData();
                  },
                  activities: _activities,
                ),
          );
        },
      ),
    );
  }
}

class AddMoodBottomSheet extends StatefulWidget {
  final Function(String, List<String>) onMoodAdded;
  final List<String> activities;

  const AddMoodBottomSheet({
    Key? key,
    required this.onMoodAdded,
    required this.activities,
  }) : super(key: key);

  @override
  State<AddMoodBottomSheet> createState() => _AddMoodBottomSheetState();
}

class _AddMoodBottomSheetState extends State<AddMoodBottomSheet> {
  String _selectedMood = 'Good';
  List<String> _selectedActivities = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling today?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMoodOption('Amazing', '😂'),
              _buildMoodOption('Good', '🙂'),
              _buildMoodOption('Anxious', '😰'),
              _buildMoodOption('Angry', '😠'),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'What activities did you do?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children:
                widget.activities.map((activity) {
                  final isSelected = _selectedActivities.contains(activity);
                  return FilterChip(
                    label: Text(activity),
                    selected: isSelected,
                    selectedColor: const Color(0xFFE75A7C).withOpacity(0.2),
                    checkmarkColor: const Color(0xFFE75A7C),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedActivities.add(activity);
                        } else {
                          _selectedActivities.remove(activity);
                        }
                      });
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onMoodAdded(_selectedMood, _selectedActivities);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE75A7C),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Save', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodOption(String mood, String emoji) {
    final isSelected = _selectedMood == mood;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = mood;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? const Color(0xFFE75A7C).withOpacity(0.2)
                      : Colors.grey.shade100,
              shape: BoxShape.circle,
              border:
                  isSelected
                      ? Border.all(color: const Color(0xFFE75A7C), width: 2)
                      : null,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(height: 8),
          Text(
            mood,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFFE75A7C) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
