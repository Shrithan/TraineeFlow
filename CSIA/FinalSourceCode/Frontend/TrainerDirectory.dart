import 'package:csia/pages/TrainerDetails.dart';
import 'package:flutter/material.dart';

class TrainerDirectoryPage extends StatelessWidget {
  // Hardcoded trainer data for a tech firm
  final List<Map<String, String>> trainers = [
    {'id': '1', 'name': 'John Doe', 'batch': 'Batch A'},
    {'id': '2', 'name': 'Jane Smith', 'batch': 'Batch B'},
    {'id': '3', 'name': 'Alex Johnson', 'batch': 'Batch C'},
    {'id': '4', 'name': 'Emily Davis', 'batch': 'Batch E'},
    {'id': '5', 'name': 'Michael Lee', 'batch': 'Batch D'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainer Directory'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: trainers.length,
          itemBuilder: (context, index) {
            var trainer = trainers[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(trainer['name']!),
                subtitle: Text('Batch: ${trainer['batch']}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Navigate to the trainees list for this trainer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrainerTraineeDetailsPage(trainerId: trainer['id'].toString(), traineeName: trainer['name']!,),
                      )
                    );
                  },
                  child: Text('View Trainees'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
