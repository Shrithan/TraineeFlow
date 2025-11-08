import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';  // Import intl package

class Task {
  final String taskDescription;
  final String taskName;
  final DateTime date;

  Task({required this.taskDescription, required this.taskName, required this.date});

  factory Task.fromJson(Map<String, dynamic> json) {
    String dateString = json['date'] ?? '';
    DateTime parsedDate = DateTime.now();

    try {
      if (dateString.isNotEmpty) {
        DateFormat format = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
        parsedDate = format.parse(dateString);
      }
    } catch (e) {
      print("Error parsing date: $e");
    }

    String taskDescription = json['TaskDescription'] ?? 'No description available';
    String taskName = json['TaskName'] ?? 'Unnamed Task';

    return Task(
      taskDescription: taskDescription,
      taskName: taskName,
      date: parsedDate,
    );
  }
}

class CalendarScreen extends StatefulWidget {
  final String trainee_username;

  CalendarScreen({required this.trainee_username});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<Task>> _events;
  late List<Task> _selectedDayTasks;
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _events = {};
    _selectedDayTasks = [];
    _fetchTasksForDate(_selectedDay);
  }

  // Fetch tasks from the backend for the selected day
  Future<void> _fetchTasksForDate(DateTime date) async {
    final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final response = await http.get(Uri.parse('http://127.0.0.1:5000/tasks?date=$formattedDate&trainee_name=${widget.trainee_username}'));

    if (response.statusCode == 200) {
      List<Task> tasks = (json.decode(response.body) as List)
          .map((data) => Task.fromJson(data))
          .toList();

      setState(() {
        _events[date] = tasks;
        _selectedDayTasks = tasks;
      });
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  // Display tasks for the selected day
  Widget _buildTaskList() {
    // When no tasks are present on the selected day.
    if (_selectedDayTasks.isEmpty) {
      return const Center(
        child: Text(
          'No tasks due for the day.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 208, 39, 39)),
        ),
      );
    }

    // When tasks are present on a given day
    return ListView.builder(
      itemCount: _selectedDayTasks.length,
      itemBuilder: (context, index) {
        final task = _selectedDayTasks[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            title: Text(
              task.taskName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Description: ${task.taskDescription}',
              style: const TextStyle(fontSize: 14),
            ),
            trailing: const Icon(Icons.add_task, color: Color.fromARGB(255, 44, 102, 209)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar of : ${widget.trainee_username}'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _selectedDayTasks = _events[selectedDay] ?? [];
                });
                _fetchTasksForDate(selectedDay);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.green),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.green),
              ),
              calendarStyle: CalendarStyle(
                todayTextStyle: TextStyle(color: Colors.white),
                todayDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: Colors.white),
                outsideTextStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: _buildTaskList(),
          ),
        ],
      ),
    );
  }
}