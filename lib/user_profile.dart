import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

import 'API/api.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, TextEditingController> _controllers = {
    'uname': TextEditingController(),
    'uemail': TextEditingController(),
    'upass': TextEditingController(),
    'umobile': TextEditingController(),
    'ucity': TextEditingController(),
    'ustreet': TextEditingController(),
    'uhouse': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndInitialize();
  }

  void _fetchUserDataAndInitialize() async {
    var userData = await Api.fetchUser(); // Assume this returns a Map<String, dynamic> of user data
    if (userData != null) {
      setState(() {
        _controllers['uname']?.text = userData['uname'] ?? '';
        _controllers['uemail']?.text = userData['uemail'] ?? '';
        _controllers['upass']?.text = userData['upass'] ?? '';
        _controllers['umobile']?.text = userData['umobile'] ?? '';
        _controllers['ucity']?.text = userData['ucity'] ?? '';
        _controllers['ustreet']?.text = userData['ustreet'] ?? '';
        _controllers['uhouse']?.text = userData['uhouse'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Widget _editableField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        actions: [
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Collect form data
                  Map<String, dynamic> updatedUserData = _collectFormData();

                  // Assume you have a method to update user details that returns a Future<bool>
                  bool success = await Api.updateUserDetails(updatedUserData);

                  // Provide feedback
                  String message = success
                      ? 'Profile updated successfully!'
                      : 'Failed to update profile.';
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(message)));

                  // Optionally refresh user data on success or navigate away
                  if (success) {
                    // Refresh the profile page or navigate to another page as needed
                    // For example: Navigator.pop(context); to go back
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Please correct the errors in the form.')),
                  );
                }
              }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _editableField(
                label: 'Name',
                icon: Icons.person,
                controller: _controllers['uname']!,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              _editableField(
                label: 'Email',
                icon: Icons.email,
                controller: _controllers['uemail']!,
                validator: (value) => EmailValidator.validate(value ?? '')
                    ? null
                    : "Please enter a valid email",
              ),
              _editableField(
                label: 'Password',
                icon: Icons.lock,
                controller: _controllers['upass']!,
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              _editableField(
                label: 'Mobile Number',
                icon: Icons.phone,
                controller: _controllers['umobile']!,
                validator: (value) {
                  if (value == null || value.length != 10) {
                    return 'Mobile Number must be 10 digits';
                  }
                  return null;
                },
              ),
              _editableField(
                label: 'City',
                icon: Icons.location_city,
                controller: _controllers['ucity']!,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              _editableField(
                label: 'Street Address',
                icon: Icons.streetview,
                controller: _controllers['ustreet']!,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your street address';
                  }
                  return null;
                },
              ),
              _editableField(
                label: 'House Details',
                icon: Icons.home,
                controller: _controllers['uhouse']!,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your house details';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _collectFormData() {
    return {
      'uname': _controllers['uname']?.text ?? '',
      'uemail': _controllers['uemail']?.text ?? '',
      'upass': _controllers['upass']?.text ?? '',
      'umobile': _controllers['umobile']?.text ?? '',
      'ucity': _controllers['ucity']?.text ?? '',
      'ustreet': _controllers['ustreet']?.text ?? '',
      'uhouse': _controllers['uhouse']?.text ?? '',
    };
  }
}
