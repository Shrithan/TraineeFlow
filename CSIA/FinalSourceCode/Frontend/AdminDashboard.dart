import 'package:csia/main.dart';
import 'package:csia/pages/AdminLogin.dart';
import 'package:csia/pages/TrainerDetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  final String userType;

  DashboardScreen({required this.userType});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int traineeCount = 0;
  int trainerCount = 0;
  bool isLoading = true;
  String errorMessage = "";

  Future<void> fetchCounts() async {
    try {
      final traineeResponse = await http.get(Uri.parse('http://127.0.0.1:5000/get_row_count/Trainee_Batches'));
      final trainerResponse = await http.get(Uri.parse('http://127.0.0.1:5000/get_row_count/Trainers'));

      if (traineeResponse.statusCode == 200 && trainerResponse.statusCode == 200) {
        setState(() {
          traineeCount = json.decode(traineeResponse.body)['row_count'] ?? 0;
          trainerCount = json.decode(trainerResponse.body)['row_count'] ?? 0;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load data.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred: $e";
        isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchTrainers() async {
    final response = await http.post(Uri.parse('http://127.0.0.1:5000/get_trainers_information'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['trainers_information'];
      return List<Map<String, dynamic>>.from(data.map((item) => {
            'id': item[0],
            'name': item[1],
            'goal': item[2],
            'audience': item[3],
          }));
    } else {
      throw Exception("Failed to load trainers information.");
    }
  }

  Future<List<List<dynamic>>> fetchBatchProgress() async {
    final response = await http.post(Uri.parse('http://127.0.0.1:5000/get_batch_progress'));
    if (response.statusCode == 200) {
      return List<List<dynamic>>.from(json.decode(response.body)['batch_progress']
          .map((item) => [item[0], double.tryParse(item[1].toString()) ?? 0.0]));
    } else {
      throw Exception("Failed to fetch batch progress.");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard",
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],


      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to Add User Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminPage()),
          );

        },
        label: Text("Add User", style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),),
        icon: Icon(Icons.person_add, color: Colors.white),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Counts Section
                    _buildCountsSection(),

                    const SizedBox(height: 20),

                    // Trainees Directory and Batch Progress (Side by Side)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Trainees Directory
                        Expanded(
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future: fetchTrainers(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return _buildErrorCard("Failed to load trainers.");
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return _buildErrorCard("No trainers found.");
                              } else {
                                return _buildTrainersDirectory(snapshot.data!);
                              }
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Batch Progress
                        Expanded(
                          child: FutureBuilder<List<List<dynamic>>>(
                            future: fetchBatchProgress(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return _buildErrorCard("Failed to load batch progress.");
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return _buildErrorCard("No batch progress available.");
                              } else {
                                return _buildBatchProgress(snapshot.data!);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCountsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCountCard(Icons.person, "Trainees", traineeCount, Colors.blue),
            _buildCountCard(Icons.school, "Trainers", trainerCount, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildCountCard(IconData icon, String title, int count, Color color) {
    return Column(
      children: [
        Icon(icon, size: 36, color: color),
        Text(
          count.toString(),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(title, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  // Widget _buildTrainersDirectory(List<Map<String, dynamic>> trainers) {
  //   return Card(
  //     elevation: 4,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             "Trainers Directory",
  //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //           ),
  //           const SizedBox(height: 10),
  //           ...trainers.map((trainer) {
  //             return ListTile(
  //               leading: Icon(Icons.person, color: Colors.blue),
  //               title: Text(trainer['name']),
  //               subtitle: Text("Goal: ${trainer['goal']}"),
  //               trailing: Icon(Icons.arrow_forward_ios),
  //               onTap: () {
  //                 // Navigate to Trainer Details
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) => TrainerTraineeDetailsPage(
  //                       trainerId: trainer['id'].toString(),
  //                       traineeName: trainer['name'],
  //                     ),
  //                   ),
  //                 );
  //               },
  //             );
  //           }).toList(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildTrainersDirectory(List<Map<String, dynamic>> trainers) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Trainers Directory",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Vertical carousel of trainer cards
          SizedBox(
            height: 550, // Set height for the carousel slider
            child: ListView.builder(
              scrollDirection: Axis.vertical, // Make it a vertical scroll
              itemCount: trainers.length,
              itemBuilder: (context, index) {
                final trainer = trainers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      leading: Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.blue,
                      ),
                      title: Text(
                        trainer['name'], // Trainer name
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Goal: ${trainer['goal']}", // Training goal
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            "Audience: ${trainer['audience']}", // Target audience
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to Trainer Details Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrainerTraineeDetailsPage(
                              trainerId: trainer['id'].toString(),
                              traineeName: trainer['name'],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildBatchProgress(List<List<dynamic>> batchProgress) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Batch Progress",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...batchProgress.map((batch) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(batch[0]),
                  LinearProgressIndicator(
                    value: batch[1],
                    backgroundColor: Colors.grey[200],
                    color: Colors.green,
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      ),
    );
  }
}