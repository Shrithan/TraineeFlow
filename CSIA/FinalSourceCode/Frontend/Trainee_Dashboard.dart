import 'package:csia/main.dart';
import 'package:csia/pages/Feedback_Page.dart';
import 'package:csia/pages/Trainee_Tasks.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding

class TraineeDashboardPage extends StatefulWidget {
  final String trainee_name;

  TraineeDashboardPage({required this.trainee_name});

  @override
  _TraineeDashboardPageState createState() => _TraineeDashboardPageState();
}

class _TraineeDashboardPageState extends State<TraineeDashboardPage> {
  String trainerName = '';
  String traineeName = '';
  bool showTrainerDetails = false;

  int trainerExperience = 0;
  String trainerLocation = '';
  String trainerTechnicalSkills = '';
  String projectMapping = '';
  String businessDomainExpertise = '';
  String trainingStyles = '';
  String softSkills = '';
  String learningManagementSkills = '';
  String languageProficiency = '';
  String availabilityAndFlexibility = '';
  String trainingGoals = '';
  String trainingDuration = '';
  String targetAudience = '';
  double matchScore = 0.0;

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/get_final_trainer'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        traineeName = widget.trainee_name;
        trainerName = data['trainer_name'];
        trainerExperience = data['trainer_experience'];
        trainerLocation = data['trainer_location'];
        trainerTechnicalSkills = data['trainer_technical_skills'];
        projectMapping = data['project_mapping'];
        businessDomainExpertise = data['business_domain_expertise'];
        trainingStyles = data['training_styles'];
        softSkills = data['soft_skills'];
        learningManagementSkills = data['learning_management_skills'];
        languageProficiency = data['language_proficiency'];
        availabilityAndFlexibility = data['availability_and_flexibility'];
        trainingGoals = data['training_goals'];
        trainingDuration = data['training_duration'];
        targetAudience = data['target_audience'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Green Top Border
          Container(
            height: 10,
            color: Colors.green,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar Section
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 40), // Spacer for centering the title
                      Text(
                        'Trainee Dashboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            widget.trainee_name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.logout, color: Colors.green),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Dashboard Cards
                Expanded(
                  child: Column(
                    children: [
                      // Assigned Trainer Card
                      _buildCard(
                        context,
                        title: 'Assigned Trainer',
                        subtitle: trainerName,
                        icon: Icons.school,
                        onPressed: () {
                          setState(() {
                            showTrainerDetails = !showTrainerDetails;
                          });
                        },
                      ),
                      if (showTrainerDetails)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Trainer Details',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              SizedBox(height: 10),
                              // Details Section
                              Card(
                                elevation: 3,
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailRow('Name', trainerName),
                                      _buildDetailRow('Experience', '$trainerExperience years'),
                                      _buildDetailRow('Location', trainerLocation),
                                      _buildDetailRow('Technical Skills', trainerTechnicalSkills),
                                      _buildDetailRow('Domain Expertise', businessDomainExpertise),
                                      _buildDetailRow('Training Styles', trainingStyles),
                                      _buildDetailRow('Soft Skills', softSkills),
                                      _buildDetailRow('Management Skills', learningManagementSkills),
                                      _buildDetailRow('Language Proficiency', languageProficiency),
                                      _buildDetailRow('Training Goals', trainingGoals),
                                      _buildDetailRow('Training Duration', trainingDuration),
                                      _buildDetailRow('Target Audience', targetAudience),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 20),

                      // Trainee Tasks Card
                      _buildCard(
                        context,
                        title: 'Trainee Tasks',
                        icon: Icons.task,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CalendarScreen(
                                trainee_username: widget.trainee_name,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),

                      // Feedback Button
                      FloatingActionButton.extended(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FeedbackPage(trainee_name: traineeName),
                            ),
                          );
                        },
                        label: Text('Submit Feedback',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),),
                        icon: Icon(Icons.feedback, color: Colors.white),
                        backgroundColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Colors.green, size: 40),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 16)) : null,
        trailing: Icon(Icons.arrow_forward, color: Colors.green),
        onTap: onPressed,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }                        


}