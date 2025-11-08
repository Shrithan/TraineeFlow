import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedbackPage extends StatelessWidget {
  final TextEditingController _feedbackController = TextEditingController();
  final String trainee_name;

  FeedbackPage({required this.trainee_name});

  Future<void> sendFeedback(given_feedback) async {
    http.post(
      Uri.parse('http://127.0.0.1:5000/add_trainee_feedback'), // Replace with your backend URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'Feedback': given_feedback,
        'TraineeName': trainee_name
        
      }),
    );   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How did you find the trainer?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Type your feedback here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  String feedback = _feedbackController.text;
                  // Add logic to send feedback (e.g., API call or local storage)
                  print("Feedback Sent: $feedback");
                  sendFeedback(feedback);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Feedback sent successfully!"),
                    ),
                  );
                  _feedbackController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Send Feedback',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}