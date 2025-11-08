import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';

class TrainerTraineeDetailsPage extends StatelessWidget {
  final String trainerId;
  final String traineeName;

  TrainerTraineeDetailsPage({required this.trainerId , required this.traineeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainees of $traineeName',
                    style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),        
                ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getTraineesAndStatusInfo(trainerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text('No Trainees are Assigned yet.',
                style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                  ),
                ),
              );
            }

            final trainees = snapshot.data!;
            return ListView.builder(
              itemCount: trainees.length,
              itemBuilder: (context, index) {
                var trainee = trainees[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(trainee['name']),
                    subtitle: Text('Status: ${trainee['status']}'),
                    trailing: trainee['status'] == 'Completed'
                        ? ElevatedButton(
                            onPressed: () {
                              _generateReport(context, trainee['name']);
                            },
                            child: Text('Generate Report'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent,
                            ),
                          )
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

void _generateReport(BuildContext context, String traineeName) async {
  const url = 'http://127.0.0.1:5000/generate-pdf'; // Replace with backend IP
  final payload = jsonEncode({'trainee_name': traineeName});
  
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: payload,
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report generated for $traineeName')),
      );
      // You can also open the file using the Flutter file downloader plugin
    } else {
      print('Failed to generate PDF');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate report')),
      );
    }
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
  }
}

Future<List<Map<String, dynamic>>> getTraineesAndStatusInfo(trainerId) async {
  try {
    print(trainerId);
    const url = 'http://127.0.0.1:5000/get_trainees_status_info';
    final payload = jsonEncode({'trainer_id': trainerId});
    
    final response = await http.post(
                                    Uri.parse(url),
                                    headers: {'Content-Type': 'application/json'},
                                    body: payload
                                    );

    // print("In TrainerDetails File :::: ");
    // print(response.body);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var trainees_and_status_list = data['trainees_and_status_info'] ?? [];

      // Convert the list of tuples into a list of maps
      return List<Map<String, dynamic>>.from(
        trainees_and_status_list.map((trainee) => {
          "name": trainee[0], // Trainee Name
          "status": trainee[1], // Status
        }),
      );
     } else {
      throw Exception('Failed to fetch trainees information. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching trainees information: $e');
  }
}


}