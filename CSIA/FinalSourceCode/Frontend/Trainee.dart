// import 'package:csia/pages/Trainee_Tasks.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert'; // For JSON decoding

// class TraineeDashboardPage extends StatefulWidget {
//   final String trainee_name;

//   TraineeDashboardPage({required this.trainee_name});
//   @override
//   _TraineeDashboardPageState createState() => _TraineeDashboardPageState();
// }

// class _TraineeDashboardPageState extends State<TraineeDashboardPage> {
//   String trainerName = '';
//   String traineeName = '';  // Example trainee name
//   String trainerPhotoUrl = 'https://via.placeholder.com/150';  // Example image URL
//   String traineePhotoUrl = 'https://via.placeholder.com/150';  // Example image URL

//   // New fields to handle trainer data
//   int trainerExperience = 0;
//   String trainerLocation = '';
//   String trainerTechnicalSkills = '';
//   String projectMapping = '';
//   String businessDomainExpertise = '';
//   String trainingStyles = '';
//   String softSkills = '';
//   String learningManagementSkills = '';
//   String languageProficiency = '';
//   String availabilityAndFlexibility = '';
//   String trainingGoals = '';
//   String trainingDuration = '';
//   String targetAudience = '';
//   double matchScore = 0.0;

//   // Method to fetch data from Flask backend
//   Future<void> fetchData() async {
//     final response = await http.get(Uri.parse('http://127.0.0.1:5000/get_final_trainer'));

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body); // Assuming the response is a list of trainers
//       print(data);

//       setState(() {
//         traineeName = widget.trainee_name;
//         trainerName = data['trainer_name'];
//         trainerExperience = data['trainer_experience'];
//         trainerLocation = data['trainer_location'];
//         trainerTechnicalSkills = data['trainer_technical_skills'];
//         projectMapping = data['project_mapping'];
//         businessDomainExpertise = data['business_domain_expertise'];
//         trainingStyles = data['training_styles'];
//         softSkills = data['soft_skills'];
//         learningManagementSkills = data['learning_management_skills'];
//         languageProficiency = data['language_proficiency'];
//         availabilityAndFlexibility = data['availability_and_flexibility'];
//         trainingGoals = data['training_goals'];
//         trainingDuration = data['training_duration'];
//         targetAudience = data['target_audience'];
//         matchScore = data['match_score'].toDouble(); // Handling match_score (Decimal to Double)
//       });
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchData(); // Fetch data when the page is initialized
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Trainee Dashboard'),
//         actions: [
//           CircleAvatar(
//             backgroundImage: NetworkImage(traineePhotoUrl),
//           ),
//           SizedBox(width: 10),
//           Text(traineeName),
//           SizedBox(width: 20),
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Row to display both cards side by side
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 // Trainer Information Card
//                 _buildCard(
//                   context,
//                   title: 'Assigned Trainer: $trainerName',
//                   imageUrl: trainerPhotoUrl,
//                   buttonText: 'View Profile',
//                   onPressed: () {
//                     // Navigate to trainer profile
//                   },
//                 ),
//                 // Task Information Card
//                 _buildCard(
//                   context,
//                   title: 'Trainee Tasks',
//                   imageUrl: 'https://via.placeholder.com/150', // You can update with task-related image
//                   buttonText: 'View Tasks',
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => CalendarScreen(trainee_username: widget.trainee_name,)),
//                     );
//                     // Navigate to tasks page or show tasks
//                   },
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             // Displaying the trainer details
//             Text('Trainer Experience: $trainerExperience years'),
//             Text('Trainer Location: $trainerLocation'),
//             Text('Technical Skills: $trainerTechnicalSkills'),
//             Text('Project Mapping: $projectMapping'),
//             Text('Business Domain Expertise: $businessDomainExpertise'),
//             Text('Training Styles: $trainingStyles'),
//             Text('Soft Skills: $softSkills'),
//             Text('Learning Management Skills: $learningManagementSkills'),
//             Text('Language Proficiency: $languageProficiency'),
//             Text('Availability and Flexibility: $availabilityAndFlexibility'),
//             Text('Training Goals: $trainingGoals'),
//             Text('Training Duration: $trainingDuration'),
//             Text('Target Audience: $targetAudience'),
//             Text('Match Score: ${matchScore.toStringAsFixed(2)}'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCard(BuildContext context, {
//     required String title,
//     required String imageUrl,
//     required String buttonText,
//     required VoidCallback onPressed,
//   }) {
//     return Card(
//       elevation: 4,
//       margin: EdgeInsets.symmetric(vertical: 10),
//       child: Container(
//         width: 160,  // Reduced width to make both cards fit
//         padding: EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundImage: NetworkImage(imageUrl),
//             ),
//             SizedBox(height: 10),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: onPressed,
//               child: Text(buttonText),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 disabledBackgroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
