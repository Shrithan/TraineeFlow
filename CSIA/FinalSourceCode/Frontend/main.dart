import 'dart:convert';
import 'package:csia/pages/AdminDashboard.dart';
import 'package:csia/pages/Fixed_questionnaire.dart';
import 'package:csia/pages/Trainer.dart';
import 'package:csia/pages/Trainee_Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Training Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedUserType;
  final List<String> _userTypes = ['Admin', 'Trainer', 'Trainee'];

  Future<bool> checkIfAllocated(String traineeName) async {
    final url = Uri.parse('http://127.0.0.1:5000/api/check_allocation');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'trainee_name': traineeName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['allocated'] as bool;
      } else {
        print('Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Network error: $e');
      return false;
    }
  }

  Future<void> sendAssignedTrainer(String traineeName) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/get_assigned_trainer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'TraineeName': traineeName}),
    );

    if (response.statusCode == 200) {
      print("Trainer assigned successfully");
    } else {
      print("Failed to assign trainer");
    }
  }

  Future<void> login(String username, String password) async {
    if (_selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a user type'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final url = Uri.parse('http://127.0.0.1:5000/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
        'role': _selectedUserType,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final userType = data['Role'];

      if (userType == 'Admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen(userType: userType)),
        );
      } else if (userType == 'Trainee') {
        if (await checkIfAllocated(username)) {
          sendAssignedTrainer(username);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TraineeDashboardPage(trainee_name: username)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => QuestionnairePage(trainee_name: username)),
          );
        }
      } else if (userType == 'Trainer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TrainerDashboardPage(trainer_name: username)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login failed. Please check your credentials.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 183, 216, 146), Colors.lightGreenAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 200, vertical: 100),
          child: Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedUserType,
                      items: _userTypes.map((String userType) {
                        return DropdownMenuItem<String>(
                          value: userType,
                          child: Text(userType),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedUserType = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Select User Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final username = _usernameController.text;
                        final password = _passwordController.text;
                        login(username, password);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Login', style: TextStyle(fontSize: 18, color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}