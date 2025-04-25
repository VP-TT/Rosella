// lib/widgets/cycle_tracker_widget.dart
import 'package:flutter/material.dart';

class CycleTrackerWidget extends StatefulWidget {
  const CycleTrackerWidget({Key? key}) : super(key: key);

  @override
  State<CycleTrackerWidget> createState() => CycleTrackerWidgetState();
}

class CycleTrackerWidgetState extends State<CycleTrackerWidget> {
  int currentDay = 2; // Current day in cycle
  int cycleLength = 28; // Default cycle length
  late DateTime lastPeriodStart;
  late DateTime nextPeriodStart;
  int daysUntilNextPeriod = 0;

  @override
  void initState() {
    super.initState();
    // Initialize with a date (e.g., today minus currentDay)
    lastPeriodStart = DateTime.now().subtract(Duration(days: currentDay));
    _calculateNextPeriod();
  }

  void _calculateNextPeriod() {
    nextPeriodStart = lastPeriodStart.add(Duration(days: cycleLength));
    daysUntilNextPeriod = _daysBetween(DateTime.now(), nextPeriodStart);
    setState(() {});
  }

  int _daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  @override
  Widget build(BuildContext context) {
    double progress = currentDay / cycleLength;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('Current Cycle', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  color: const Color(0xFFE75A7C),
                  backgroundColor: const Color(0xFFFCECF1),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Day', style: TextStyle(color: Color(0xFFE75A7C))),
                  Text(
                    '$currentDay',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoBox(
                'Days until next period',
                '$daysUntilNextPeriod days',
              ),
              _buildInfoBox(
                'Next Period',
                '${nextPeriodStart.day}/${nextPeriodStart.month}/${nextPeriodStart.year}',
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Only allow editing cycle length
          Row(
            children: [
              const Expanded(flex: 2, child: Text('Cycle Length:')),
              Expanded(
                flex: 3,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter cycle length',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  controller: TextEditingController(
                    text: cycleLength.toString(),
                  ),
                  onChanged: (value) {
                    int? val = int.tryParse(value);
                    if (val != null && val >= 21 && val <= 35) {
                      setState(() {
                        cycleLength = val;
                        _calculateNextPeriod();
                      });
                    }
                  },
                ),
              ),
              const Expanded(
                flex: 1,
                child: Text(' days', textAlign: TextAlign.left),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
