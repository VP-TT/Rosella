// lib/screens/symptoms_screen.dart
import 'package:flutter/material.dart';

class SymptomsScreen extends StatefulWidget {
  const SymptomsScreen({Key? key}) : super(key: key);

  @override
  State<SymptomsScreen> createState() => _SymptomsScreenState();
}

class _SymptomsScreenState extends State<SymptomsScreen> {
  String selectedMood = '';
  double weight = 58.0;
  double temperature = 36.5;
  double menstrualFlow = 2.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('23rd November 2021'),
        backgroundColor: const Color(0xFFE75A7C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Mood Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMoodOption('😀', 'Happy'),
                _buildMoodOption('🙂', 'Good'),
                _buildMoodOption('😐', 'Neutral'),
                _buildMoodOption('😕', 'Sad'),
                _buildMoodOption('😫', 'Awful'),
              ],
            ),

            const SizedBox(height: 32),

            // Weight Tracker
            _buildSliderSection(
              title: 'Weight',
              value: weight,
              min: 40,
              max: 100,
              unit: 'kg',
              onChanged: (value) {
                setState(() {
                  weight = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // Temperature Tracker
            _buildSliderSection(
              title: 'Temperature',
              value: temperature,
              min: 35.0,
              max: 40.0,
              unit: '°C',
              onChanged: (value) {
                setState(() {
                  temperature = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // Menstrual Flow Tracker
            _buildSliderSection(
              title: 'Menstrual flow',
              value: menstrualFlow,
              min: 0,
              max: 5,
              unit: '',
              onChanged: (value) {
                setState(() {
                  menstrualFlow = value;
                });
              },
            ),

            const SizedBox(height: 32),

            // Symptoms Checklist
            const Text(
              'Symptoms',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSymptomChip('Headache'),
                _buildSymptomChip('Cramps'),
                _buildSymptomChip('Bloating'),
                _buildSymptomChip('Fatigue'),
                _buildSymptomChip('Acne'),
                _buildSymptomChip('Mood swings'),
                _buildSymptomChip('Insomnia'),
                _buildSymptomChip('Nausea'),
              ],
            ),

            const SizedBox(height: 32),

            // Notes Section
            const Text(
              'Notes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add any additional notes here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Save functionality
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE75A7C),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Save', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodOption(String emoji, String label) {
    bool isSelected = selectedMood == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMood = label;
        });
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFD6E0) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isSelected ? const Color(0xFFE75A7C) : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFE75A7C) : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSection({
    required String title,
    required double value,
    required double min,
    required double max,
    required String unit,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFE75A7C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFFE75A7C),
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: const Color(0xFFE75A7C),
            trackHeight: 4,
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildSymptomChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (bool selected) {
        // Handle selection
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: const Color(0xFFFFD6E0),
      checkmarkColor: const Color(0xFFE75A7C),
    );
  }
}
