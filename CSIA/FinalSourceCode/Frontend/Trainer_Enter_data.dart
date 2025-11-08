import 'dart:convert';
import 'package:csia/pages/Trainer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TrainerInformationUpdatePage extends StatefulWidget {
  final String traineeName;
  final String trainerName;

  TrainerInformationUpdatePage({
    Key? key,
    required this.traineeName,
    required this.trainerName,
  }) : super(key: key);
  @override
  _TrainerInformationUpdatePageState createState() =>
      _TrainerInformationUpdatePageState();
}

class _TrainerInformationUpdatePageState
    extends State<TrainerInformationUpdatePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each text field
  final TextEditingController _attendanceFeedback =
      TextEditingController();
  final TextEditingController _skillFeedback =
      TextEditingController();
  final TextEditingController _engagementFeedback =
      TextEditingController();
  final TextEditingController _assignementFeedback =
      TextEditingController();
  final TextEditingController _communicationFeedback =
      TextEditingController();
  final TextEditingController _teamwordFeedback =
      TextEditingController();
  final TextEditingController _problemsolvingFeedback =
      TextEditingController();
  final TextEditingController _adaptabilityFeedback =
      TextEditingController();
  final TextEditingController _additionalFeedback =
      TextEditingController();
  final TextEditingController _daysAttended = TextEditingController();
  final TextEditingController _totalDays = TextEditingController();
  final TextEditingController _preSkill = TextEditingController();
  final TextEditingController _postSkill = TextEditingController();
  final TextEditingController _engagementAmount = TextEditingController();
  final TextEditingController _completedAssignments =
      TextEditingController();
  final TextEditingController _totalAssigments = TextEditingController();
  final TextEditingController _verbalCommunication =
      TextEditingController();
  final TextEditingController _writtenCommunication =
      TextEditingController();
  final TextEditingController _teamContribution = TextEditingController();
  final TextEditingController _conflictManagement = TextEditingController();
  final TextEditingController _analyticalSkills = TextEditingController();
  final TextEditingController _creativity = TextEditingController();
  final TextEditingController _learningCurve = TextEditingController();
  final TextEditingController _overallScore = TextEditingController();
  final TextEditingController _exitResponse1 = TextEditingController();
  final TextEditingController _exitResponse2 = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _attendanceFeedback.dispose();
    _skillFeedback.dispose();
    _engagementFeedback.dispose();
    _assignementFeedback.dispose();
    _communicationFeedback.dispose();
    _teamwordFeedback.dispose();
    _problemsolvingFeedback.dispose();
    _adaptabilityFeedback.dispose();
    _additionalFeedback.dispose();
    _daysAttended.dispose();
    _totalDays.dispose();
    _preSkill.dispose();
    _postSkill.dispose();
    _engagementAmount.dispose();
    _completedAssignments.dispose();
    _totalAssigments.dispose();
    _verbalCommunication.dispose();
    _writtenCommunication.dispose();
    _teamContribution.dispose();
    _conflictManagement.dispose();
    _analyticalSkills.dispose();
    _creativity.dispose();
    _learningCurve.dispose();
    _overallScore.dispose();
    _exitResponse1.dispose();
    _exitResponse2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback of : ${widget.traineeName}',
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Training Completion Status
                _buildTextField(
                  label: 'Attendance Feedback',
                  controller: _attendanceFeedback,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  label: 'Skill Feedback',
                  controller: _skillFeedback,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  label: 'Engagement Feedback',
                  controller: _engagementFeedback,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  label: 'Assignment Feedback',
                  controller: _assignementFeedback,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  label: 'Communication Feedback',
                  controller: _communicationFeedback,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  label: 'Teamwork Feedback',
                  controller: _teamwordFeedback,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  label: 'Problem Solving Feedback',
                  controller: _problemsolvingFeedback,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  label: 'Adaptability Feedback',
                  controller: _adaptabilityFeedback,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  label: 'Additional Feedback',
                  controller: _additionalFeedback,
                ),
                SizedBox(height: 10),

                // Number Fields in Row (Horizontal layout)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNumberField(label: 'Days Attended', controller: _daysAttended, maxValue: 100000000000),
                    SizedBox(width: 10),
                    _buildNumberField(label: 'Total Days', controller: _totalDays, maxValue: 100000000000),
                    SizedBox(width: 10),
                    _buildNumberField(label: 'Pre Skill', controller: _preSkill, maxValue: 100),
                    SizedBox(width: 10),
                    _buildNumberField(label: 'Post Skill', controller: _postSkill, maxValue: 100,)
                  ],
                ),
                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNumberField(label: 'Engagement Amount', controller: _engagementAmount, maxValue: 100),
                    SizedBox(width: 10),
                    _buildNumberField(label: 'Completed Assignments', controller: _completedAssignments, maxValue: 100000000000),
                    SizedBox(width: 10),
                    _buildNumberField(label: 'Total Assignments', controller: _totalAssigments, maxValue: 100000000000),
                    SizedBox(width: 10),
                    _buildNumberField(label: 'Verbal Communication', controller: _verbalCommunication, maxValue: 10),
                  ],
                ),
                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNumberField(label: 'Written Communication', controller: _writtenCommunication, maxValue: 10),
                    SizedBox(width: 10),
                    _buildNumberField(label: 'Team Contribution', controller: _teamContribution, maxValue: 10),
                    SizedBox(width: 10),
                    _buildNumberField(label: 'Conflict Management', controller: _conflictManagement, maxValue: 10),
                    SizedBox(width: 10),
                    _buildNumberField(label: 'Analytical Skills', controller: _analyticalSkills, maxValue: 10),
                  ],
                ),
                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNumberField(label: 'Creativity', controller: _creativity, maxValue: 10),
                    SizedBox(width: 10),
                    _buildNumberField(label: 'Learning Curve', controller: _learningCurve, maxValue: 10),
                    SizedBox(width: 10),
                    _buildNumberField(label: 'Overall Score', controller: _overallScore, maxValue: 100),
                  ],
                ),
                SizedBox(height: 20),

                _buildTextField(
                  label: 'Exit Response 1',
                  controller: _exitResponse1,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  label: 'Exit Response 2',
                  controller: _exitResponse2,
                ),
                SizedBox(height: 30),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _submitForm();
                    },
                    child: Text('Submit',
                        style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),        
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,

      // Checks if the value is null and prompts the user to enter data
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';     
        }
        return null;
      },
    );
  }

  Widget _buildNumberField({
  required String label,
  required TextEditingController controller,
  required int maxValue,
}) {
  return Expanded(
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        // Validation to make sure int values are entered
        final intValue = int.tryParse(value);
        if (intValue == null) {
          return 'Please enter a valid number';
        }
        // Validation to make sure the score or days are entered within the limit
        if (intValue > maxValue) {
          return 'Value must not exceed $maxValue';
        }
        return null;
      },
    ),
  );
}

  // Submit form and send data to Flask backend
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Create a map of the form data
      final Map<String, String> formData = {
        'traineeName': widget.traineeName,
        'trainerName': widget.trainerName,
        'attendance_feedback': _attendanceFeedback.text,
        'skill_feedback': _skillFeedback.text,
        'engagement_feedback': _engagementFeedback.text,
        'assignement_feedback': _assignementFeedback.text,
        'communication_feedback': _communicationFeedback.text,
        'teamwork_feedback': _teamwordFeedback.text,
        'problemsolving_feedback': _problemsolvingFeedback.text,
        'adaptability_feedback': _adaptabilityFeedback.text,
        'additional_feedback': _additionalFeedback.text,
        'days_attended': _daysAttended.text,
        'total_days': _totalDays.text,
        'pre_skill': _preSkill.text,
        'post_skill': _postSkill.text,
        'engagement_amount': _engagementAmount.text,
        'completed_assignments': _completedAssignments.text,
        'total_assignments': _totalAssigments.text,
        'verbal_communication': _verbalCommunication.text,
        'written_communication': _writtenCommunication.text,
        'team_contribution': _teamContribution.text,
        'conflict_management': _conflictManagement.text,
        'analytical_skills': _analyticalSkills.text,
        'creativity': _creativity.text,
        'learning_curve': _learningCurve.text,
        'overall_score': _overallScore.text,
        'exit_response_1': _exitResponse1.text,
        'exit_response_2': _exitResponse2.text,
      };

      // Send the data to the Flask backend
      final url = Uri.parse('http://127.0.0.1:5000/api/update_trainer_info'); // Replace with your Flask URL
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200) {
        // If the request is successful, show a success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Information Updated')));
      } else {
        // If the request fails, show an error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update information')));
      }
    }
  }
}
