import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddTaskPage extends StatefulWidget {
  final String trainer_name;

  AddTaskPage({Key? key, required this.trainer_name}) : super(key: key);
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  // Controllers to capture text input from the form fields
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDeadlineController = TextEditingController();
  final TextEditingController _taskDescriptionController = TextEditingController();

 

  // Function to handle form submission
  void _submitForm() {
    final String taskName = _taskNameController.text;
    final String taskDeadline = _taskDeadlineController.text;
    final String taskDescription = _taskDescriptionController.text;
  


    if (taskName.isNotEmpty && taskDeadline.isNotEmpty && taskDescription.isNotEmpty) {
      // Here you can handle the task submission, e.g., save it to a database or show a success message
      http.post(
            Uri.parse('http://127.0.0.1:5000/add_task'), // Replace with your backend URL
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'TaskName': taskName,
              'TaskDescription': taskDescription,
              'TaskDeadline': taskDeadline,
              'TrainerName': widget.trainer_name
            }),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task "$taskName" added successfully!')),
      );
      // Clear the form fields
      _taskNameController.clear();
      _taskDeadlineController.clear();
      _taskDescriptionController.clear();
    } else {
      // Show an error message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task',
                    style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),        
                ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Name Field
            TextFormField(
              controller: _taskNameController,
              decoration: InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
              ),
              maxLength: 50,
            ),
            SizedBox(height: 16.0),

            // Task Deadline Field
            TextFormField(
              controller: _taskDeadlineController,
              decoration: InputDecoration(
                labelText: 'Task Deadline',
                border: OutlineInputBorder(),
                hintText: 'Enter date (e.g., 2024-12-31)',
              ),
            ),
            SizedBox(height: 16.0),

            // Task Description Field
            TextFormField(
              controller: _taskDescriptionController,
              decoration: InputDecoration(
                labelText: 'Task Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,  // Makes the description field multi-line
            ),
            SizedBox(height: 20.0),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  'Add Task',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}