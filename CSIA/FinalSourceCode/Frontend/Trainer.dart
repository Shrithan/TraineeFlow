import 'package:csia/main.dart';
import 'package:csia/pages/Add_Task.dart';
import 'package:csia/pages/Trainer_Enter_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrainerDashboardPage extends StatefulWidget {
  final String trainer_name;

  TrainerDashboardPage({required this.trainer_name});

  @override
  _TrainerDashboardPageState createState() => _TrainerDashboardPageState();
}

class _TrainerDashboardPageState extends State<TrainerDashboardPage> {
  List<String> traineeNames = [];
  final List<bool> taskCompleted = [
    true, false, true, true, false, false, true,
    true, false, true, true, false, false, true
  ];

  @override
  void initState() {
    super.initState();
    getAssignedTrainees(); // Fetch data when the widget initializes
  }
Future<void> getAssignedTrainees() async {

  await sendTrainerID(widget.trainer_name);
  final response = await http.get(Uri.parse('http://127.0.0.1:5000/send_all_trainees'));

  if (response.statusCode == 200) {

    final data = json.decode(response.body);
    
    // Safely convert all elements to strings
    setState(() {
      traineeNames = List<String>.from(
        data.map((e) => e.toString())
      );
    });

    print(traineeNames); // Debug the final list
  } else {
    print("Failed to fetch trainee names.");
  }
}

  Future<void> sendTrainerID(trainerID) async {

    // print("I came to Send Trainer ID first");
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/get_assigned_trainees'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'TrainerID': trainerID
      }),
    );

    if (response.statusCode == 200) {
      print("Sent trainerID succesfully");
    } else {
      print("Failed to send trainer ID");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainer Dashboard',
                    style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),        
                ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Redirect to LoginScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],

      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Text(
              'List of the currently assigned Trainees to you!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Unified Trainee List with Enter Data and Status Indicator
            Expanded(
              child: ListView.builder(
                itemCount: traineeNames.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        traineeNames[index],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Status Circle (Green or Red)
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: taskCompleted[index]
                                  ? Colors.green
                                  : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 10),
                          // Enter Data Button
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to data entry page for the trainee
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TrainerInformationUpdatePage(
                                        trainerName: widget.trainer_name,
                                        traineeName: traineeNames[index],
                                      ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: taskCompleted[index]
                                  ? Colors.green[300]
                                  : Colors.red[300],
                              padding: EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: Text('Enter Feedback'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      // Add Task Button
      floatingActionButton: Container(
        width: 200, // Adjust width as needed
        height: 50, // Adjust height as needed
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTaskPage(trainer_name: widget.trainer_name,)),
            );
          },
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Optional: Adds rounded corners
          ),
          child: Text(
            'Add Task',
            style: TextStyle(
              fontSize: 16, // Increase font size if necessary
              color: Colors.white, // Set text color
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );}}
