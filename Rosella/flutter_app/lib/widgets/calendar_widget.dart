// lib/widgets/calendar_widget.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime nextPeriodStart;
  final int periodDuration;

  const CalendarWidget({
    Key? key,
    required this.nextPeriodStart,
    this.periodDuration = 5,
  }) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  late Map<DateTime, List<String>> _events;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _createEvents();
  }

  void _createEvents() {
    _events = {};

    // Add period days
    for (int i = 0; i < widget.periodDuration; i++) {
      final day = DateTime(
        widget.nextPeriodStart.year,
        widget.nextPeriodStart.month,
        widget.nextPeriodStart.day + i,
      );
      _events[day] = ['period'];
    }
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nextPeriodStart != widget.nextPeriodStart ||
        oldWidget.periodDuration != widget.periodDuration) {
      _createEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(12),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
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
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            // Check if this day is in period
            for (int i = 0; i < widget.periodDuration; i++) {
              final periodDay = DateTime(
                widget.nextPeriodStart.year,
                widget.nextPeriodStart.month,
                widget.nextPeriodStart.day + i,
              );

              if (isSameDay(day, periodDay)) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        i == 0
                            ? const Color(0xFFE75A7C)
                            : const Color(0xFFFFD6E0),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: i == 0 ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }
            }
            return null;
          },
        ),
      ),
    );
  }
}
