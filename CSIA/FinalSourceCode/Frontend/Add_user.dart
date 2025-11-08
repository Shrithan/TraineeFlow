import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedRole;
  bool _isSubmitting = false;

  // Function to add a user to the database
  Future<void> addUser() async {
    if (_nameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _selectedRole != null) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:5000/add_user'), // Replace with your backend URL
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'UserName': _nameController.text,
            'Password': _passwordController.text,
            'Role': _selectedRole,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User added successfully')),
          );
          _nameController.clear();
          _passwordController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add user')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Users'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name your program and assign roles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),

            SizedBox(height: 20),

            // Role selection dropdown
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: [
                DropdownMenuItem(value: 'Trainee', child: Text('Trainee')),
                DropdownMenuItem(value: 'Admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Role',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Show these fields only when a role is selected
            if (_selectedRole != null) ...[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Enter Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Enter Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],

            // Next button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.green, // Green button
                ),
                onPressed: _isSubmitting ? null : addUser,
                child: _isSubmitting
                    ? CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        'Next',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}