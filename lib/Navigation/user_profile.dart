import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/api.dart';
import '../Authentication/signin_screen.dart';
import '../Models/allergy_model.dart';
import '../Others/custom_text_fields.dart';
import '../main.dart';
import '../provider/cart_provider.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedAllergy; // Declare selectedAllergy variable
  List<Allergen> allergies = [];
  List<String> selectedAllergies = [];
  final Map<String, TextEditingController> _controllers = {
    'uname': TextEditingController(),
    'uemail': TextEditingController(),
    'upass': TextEditingController(),
    'umobile': TextEditingController(),
    'ucity': TextEditingController(),
    'ustreet': TextEditingController(),
    'uhouse': TextEditingController(),
  };
  final Map<String, bool> _editableStates = {
    'uname': false,
    'uemail': false,
    'upass': false,
    'umobile': false,
    'ucity': false,
    'ustreet': false,
    'uhouse': false,
    'allergies': false,
  };
  final Map<String, FocusNode> _focusNodes = {
    'uname': FocusNode(),
    'uemail': FocusNode(),
    'upass': FocusNode(),
    'umobile': FocusNode(),
    'ucity': FocusNode(),
    'ustreet': FocusNode(),
    'uhouse': FocusNode(),
    'allergies':  FocusNode(),

    // Add more for each field you need
  };

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndInitialize();
    fetchAllergies();
  }

  void _handleAddAllergy() {
    if (selectedAllergy != null && !selectedAllergies.contains(selectedAllergy)) {
      setState(() {
        selectedAllergies.add(selectedAllergy!);
      });
    }
  }

  void fetchAllergies() async {
    allergies = await Api.fetchAllergens();
  }

  void toggleEdit(String fieldKey) {
    setState(() {
      _editableStates[fieldKey] = !_editableStates[fieldKey]!;
    });

    if (_editableStates[fieldKey]!) {
      // Schedule a callback for the end of this frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[fieldKey]?.requestFocus();
      });
    }
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

        // Initialize selectedAllergies from userData, ensuring it handles the case where allergies may not exist
        selectedAllergies = List<String>.from(userData['allergies'] ?? []);
      });
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03),
      child: Scaffold(
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 32,  // Large font size for emphasis
                    fontWeight: FontWeight.bold,  // Bold for visual impact
                    color: Colors.black,  // Thematic color consistency
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    ..._controllers.entries.map((entry) {
                      String fieldLabel = entry.key.substring(1); // Remove 'u' prefix for display
                      fieldLabel = "${fieldLabel[0].toUpperCase()}${fieldLabel.substring(1)}"; // Capitalize first letter
                      IconData iconData; // Define iconData variable
                      switch (entry.key) {
                        case 'uname':
                          iconData = Icons.person;
                          break;
                        case 'uemail':
                          iconData = Icons.email;
                          break;
                        case 'upass':
                          iconData = Icons.lock;
                          break;
                        case 'umobile':
                          iconData = Icons.phone_android;
                          break;
                        case 'ucity':
                          iconData = Icons.location_city;
                          break;
                        case 'ustreet':
                          iconData = Icons.streetview;
                          break;
                        case 'uhouse':
                          iconData = Icons.home;
                          break;
                        default:
                          iconData = Icons.label; // Fallback icon
                      }
                      return CustomTextField(
                        labelText: fieldLabel.replaceAll("mobile", "Mobile Number"),
                        icon: iconData,
                        controller: entry.value,
                        editable: _editableStates[entry.key]!, // Pass the editable state
                        onEdit: () => toggleEdit(entry.key),
                        focusNode: _focusNodes[entry.key], // Pass the focusNode here
                        validator: (value) {
                          if (entry.key == 'uemail') {
                            return EmailValidator.validate(value ?? '') ? null : "Please enter a valid email";
                          }
                          if (value == null || value.isEmpty) {
                            return 'Please enter your $fieldLabel';
                          }
                          if (entry.key == 'upass' && value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          if (entry.key == 'umobile' && value.length != 10) {
                            return 'Mobile Number must be 10 digits';
                          }
                          return null;
                        },
                      );
                    }),
                    Row(
                      children: [
                        Expanded(
                          child: CustomDropdownButtonFormField<String>(
                            value: selectedAllergy,
                            labelText: 'Select Allergy',
                            items: allergies.map((allergy) {
                              return DropdownMenuItem<String>(
                                value: allergy.allergen,
                                child: Text(allergy.allergen),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedAllergy = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10), // Add some spacing between the dropdown and the button
                        ElevatedButton(
                          onPressed: _handleAddAllergy,
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    // Display selected allergies
                    if (selectedAllergies.isNotEmpty)
                      Wrap(
                        spacing: 8.0,
                        children: selectedAllergies.map((allergy) {
                          return Chip(
                            label: Text(allergy),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () {
                              setState(() {
                                selectedAllergies.remove(allergy);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        CustomElevatedButton(
                          text: 'Save Profile',
                          onPressed: () async {
                            print(selectedAllergies);
                            if (_formKey.currentState!.validate()) {
                              if (_formKey.currentState!.validate()) {
                                Map<String, dynamic> updatedUserData = _collectFormData();
                                updatedUserData = {
                                  'allergies': selectedAllergies,
                                };
                                bool success = await Api.updateUserDetails(updatedUserData);
                                String message = success ? 'Profile updated successfully!' : 'Failed to update profile.';
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please correct the errors in the form.')));
                              }
                              // Collect form data and update
                            }
                          },
                        ),
                        CustomElevatedButton(
                          text: 'Logout',
                          onPressed: () async {
                            _logoutUser();
                          },
                        ),
                      ],
                    ),


                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logoutUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAdmin', false);
      await prefs.setBool('isLoggedIn', false);
      await prefs.setString('userId', '');
      final cartProvider = Provider.of<CartProvider>(context,listen: false);
      cartProvider.clear();
      MyApp.navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const signInScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  Map<String, dynamic> _collectFormData() {
    // This function collects form data into a map
    return _controllers.map((key, value) => MapEntry(key.substring(1), value.text));
  }
}
