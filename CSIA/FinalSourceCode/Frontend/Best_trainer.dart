import 'dart:convert';
import 'package:csia/pages/Trainee_Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Trainer {

  // "TrainerID": 6,
  //   "availability_and_flexibility": "Morning, Weekends",
  //   "business_domain_expertise": "Retail",
  //   "language_proficiency": "English, Hindi",
  //   "learning_management_skills": "Moodle",
  //   "match_score": "100.00",
  //   "project_mapping": "Data Analysis",
  //   "soft_skills": "Teamwork",
  //   "target_audience": "Advanced",
  //   "trainer_experience": 2,
  //   "trainer_location": "Onsite",
  //   "trainer_name": "Sam Moe",
  //   "trainer_technical_skills": ".NET",
  //   "training_duration": "1 week",
  //   "training_goals": "Project Support",
  //   "training_styles": "Hands-on"

  final int id;
  final String name;
  final int experience;
  final String location;
  final String technicalSkills;
  final String projectMapping;
  final String businessDomainExpertise;
  final String trainingStyles;
  final String softSkills;
  final String learningManagementSkills;
  final String languageProficiency;
  final String availability;
  final String trainingGoals;
  final String trainingDuration;
  final String targetAudience;
  final double matchScore;

  Trainer({
    required this.id,
    required this.name,
    required this.experience,
    required this.location,
    required this.technicalSkills,
    required this.projectMapping,
    required this.businessDomainExpertise,
    required this.trainingStyles,
    required this.softSkills,
    required this.learningManagementSkills,
    required this.languageProficiency,
    required this.availability,
    required this.trainingGoals,
    required this.trainingDuration,
    required this.targetAudience,
    required this.matchScore,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    //print("************** Trainer JSON ******************"+ json)

    return Trainer(
      id: json['TrainerID'],
      name: json['trainer_name'],
      experience: json['trainer_experience'],
      location: json['trainer_location'],
      technicalSkills: json['trainer_technical_skills'],
      projectMapping: json['project_mapping'],
      businessDomainExpertise: json['business_domain_expertise'],
      trainingStyles: json['training_styles'],
      softSkills: json['soft_skills'],
      learningManagementSkills: json['learning_management_skills'],
      languageProficiency: json['language_proficiency'],
      availability: json['availability_and_flexibility'],
      trainingGoals: json['training_goals'],
      trainingDuration: json['training_duration'],
      targetAudience: json['target_audience'],
      matchScore: double.tryParse(json['match_score'].toString()) ?? 0.0,
    );
  }
}

class TrainersPage extends StatefulWidget {
  final String trainee_name;

  TrainersPage({required this.trainee_name});
  @override
  _TrainersPageState createState() => _TrainersPageState();
}

class _TrainersPageState extends State<TrainersPage> {
  
  late Future<List<Trainer>> futureTrainers;
  Trainer? selectedTrainer;

  Future<List<Trainer>> fetchTopFiveTrainers() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/get_best_trainer'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Trainer.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load trainers');
    }
  }

  Future<void> sendTrainerChoice(trainer_choice) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/send_trainer_choice'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'TrainerID': trainer_choice,
        'TraineeName': widget.trainee_name
      }),
    );

    if (response.statusCode == 200) {
      print("Answer submitted successfully");
    } else {
      print("Failed to submit answer");
    }
  }

  @override
  void initState() {
    super.initState();
    futureTrainers = fetchTopFiveTrainers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Trainer'),
      ),
      body: FutureBuilder<List<Trainer>>(
        future: futureTrainers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No trainers available.'));
          } else {
            final trainers = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: trainers.length,
                    itemBuilder: (context, index) {
                      final trainer = trainers[index];
                      final isSelected = selectedTrainer?.id == trainer.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTrainer = trainer;
                          });
                        },
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.all(8),
                          color: isSelected ? Colors.blue[100] : Colors.white,
                          child: ListTile(
                            title: Text(trainer.name),
                            subtitle: Text('Match Score: ${trainer.matchScore.toStringAsFixed(2)}'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (selectedTrainer != null)
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.grey[200],
                    child: Column(
                      children: [
                        Text(
                          'Selected Trainer: ${selectedTrainer!.name}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Perform action with the selected trainer
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Confirm Selection'),
                                content: Text('Do you want to proceed with ${selectedTrainer!.name}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      print(selectedTrainer!.id);
                                      sendTrainerChoice(selectedTrainer!.id);
                                       Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => TraineeDashboardPage(trainee_name: widget.trainee_name,)),
                                      );// Go to a new page with the selected trainer

                                    },
                                    child: Text('Confirm'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text('Confirm Selection'),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}