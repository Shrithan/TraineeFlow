import 'dart:convert';
import 'package:csia/pages/Best_trainer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BestTrainerPage extends StatefulWidget {
  final String trainee_name;

  const BestTrainerPage({super.key, required this.trainee_name});

  @override
  _BestTrainerPageState createState() => _BestTrainerPageState();
}

class _BestTrainerPageState extends State<BestTrainerPage> {
  late Future<void> fetchQuestionsFuture;
  Map<String, dynamic>? currentQuestion; // Holds the current question
  int questionCounter = 0; // Tracks how many questions have been answered

  @override
  void initState() {
    super.initState();
    fetchNextQuestion(); 
  }

  Future<void> fetchNextQuestion() async {
    if (questionCounter >= 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TrainersPage(trainee_name: widget.trainee_name,), // Redirect to ResultPage
        ),
      );
      return;
      
    }

    final response = await http.get(Uri.parse('http://127.0.0.1:5000/send_next_best_question'));
    if (response.statusCode == 200) {
      setState(() {
        currentQuestion = json.decode(response.body);
      });
    } else {
      print('Failed to fetch next question');
    }
  }

  // Submit an answer to the backend
  Future<void> submitAnswer(String answer) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/get_answer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'question': currentQuestion?['question'],
        'answer': answer,
      }),
    );

    if (response.statusCode == 200) {
      print("Answer submitted successfully");
    } else {
      print("Failed to submit answer");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Best Trainer"),
      ),
      body: currentQuestion == null
          ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching question
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Question ${questionCounter + 1}:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    currentQuestion?['question'] ?? 'Loading question...',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  if (currentQuestion?['options'] != null)
                    ...currentQuestion!['options']
                        .map<Widget>((option) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  await submitAnswer(option); // Submit the selected answer
                                  setState(() {
                                    questionCounter++; // Increment the question counter
                                    currentQuestion = null; // Reset current question
                                  });
                                  await fetchNextQuestion(); // Fetch the next question
                                },
                                child: Text(option),
                              ),
                            ))
                        .toList(),
                  if (questionCounter >= 4)
                    Center(
                      child: Text(
                        "You have completed the additional questions!",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}