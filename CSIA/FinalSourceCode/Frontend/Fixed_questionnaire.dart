import 'dart:convert';
import 'package:csia/pages/Dynamic_questionnaire.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QuestionnairePage extends StatefulWidget {
  final String trainee_name;

  QuestionnairePage({Key? key, required this.trainee_name}) : super(key: key);
  @override
  _QuestionnairePageState createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;
  List<String> answers = [];
  TextEditingController numberController = TextEditingController();

  Future<void> fetchQuestions() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/send_initial_questions'));

    if (response.statusCode == 200) {
      setState(() {
        questions = json.decode(response.body);
      });
    } else {
      print('Failed to load questions');
    }
  }

  Future<void> sendAnswer(String answer) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/submit_answer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'question': questions[currentQuestionIndex]['question'],
        'answer': answer,
        'attribute': questions[currentQuestionIndex]['attribute'],
      }),
    );

    if (response.statusCode == 200) {
      print("Answer sent successfully");
    } else {
      print("Failed to send answer");
    }
  }

  Future<void> sendInitializationRequest(yes_or_no) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/initialize'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'initialize_yes_or_no': yes_or_no, 
      }),
    );

    if (response.statusCode == 200) {
      print("Init request sent successfully");
    } else {
      print("Failed to send init request");
    }
  }

  Future<void> sendExperienceAnswer(String answer) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/submit_experience_answer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'question': questions[currentQuestionIndex]['question'],
        'answer': answer,
        'attribute': questions[currentQuestionIndex]['attribute'],
      }),
    );

    if (response.statusCode == 200) {
      print("Answer sent successfully");
    } else {
      print("Failed to send answer");
    }
  }
  

  @override
  void initState() {
    super.initState();
    sendInitializationRequest("yes");
    fetchQuestions();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Questionnaire')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentQuestionIndex >= questions.length) {
      // Show the final button to navigate to the next page
      return Scaffold(
        appBar: AppBar(title: Text('Questionnaire')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BestTrainerPage(trainee_name: widget.trainee_name,)),
              );
            },
            child: Text("Get the Best Trainer for You"),
          ),
        ),
      );
    }

    var currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Questionnaire')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentQuestion['question'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Check if options is "-"
            if (currentQuestion['options'] == "-")
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: numberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter your answer",
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (numberController.text.isNotEmpty) {
                        setState(() {
                          answers.add(numberController.text);

                          sendExperienceAnswer(numberController.text);

                          numberController.clear(); // Clear the field

                          if (currentQuestionIndex < questions.length - 1) {
                            currentQuestionIndex++;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => BestTrainerPage(trainee_name: widget.trainee_name,)),
                          );
                        });
                      }
                    },
                    child: Text("Submit"),
                  ),
                ],
              )
            else
              // Show options as buttons
              ...currentQuestion['options']
                  .map<Widget>((option) => OptionButton(
                        option: option,
                        onPressed: () async {
                          setState(() {
                            answers.add(option);

                            sendAnswer(option);

                            if (currentQuestionIndex < questions.length - 1) {
                              currentQuestionIndex++;
                            }
                          });
                        },
                      ))
                  .toList(),
          ],
        ),
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final String option;
  final VoidCallback onPressed;

  OptionButton({required this.option, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(option),
      ),
    );
  }
}
