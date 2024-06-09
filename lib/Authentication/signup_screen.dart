import 'package:flutter/material.dart';
import 'package:fyp2/Authentication/signin_screen.dart';
import 'package:fyp2/Models/security_question.dart';
import '../API/api.dart';
import '../Models/user_model.dart';

class signUpScreen extends StatefulWidget {
  const signUpScreen({super.key});

  @override
  State<signUpScreen> createState() => _signUpScreenState();
}

class _signUpScreenState extends State<signUpScreen> {
  final firstNameEditingController = TextEditingController();
  final secondNameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final confirmPasswordEditingController = TextEditingController();
  final securityQuestionAnswerController = TextEditingController();
  final mobileNumber = TextEditingController();
  final securityQuestions = TextEditingController();
  final _formSignUpKey = GlobalKey<FormState>();
  String error_message = "";
  String error_pwd = "";
  String? errorMessage;
  bool _obscurePassword = true; // State for password visibility
  bool _obscuredconfirmpwd = true;
  List<String> questions = [];

  @override
  void initState() {
    fetchQuestions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopSection(context),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formSignUpKey,
                child: _buildFormFields(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
              child: _buildSignUpButton(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: _buildSignInPrompt(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: const BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 80, color: Colors.white),
            SizedBox(height: 10),
            Text(
              'Create Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField(firstNameEditingController, 'Firstname', Icons.account_circle_rounded, r'^[a-zA-Z\s]+$'),
        const SizedBox(height: 16),
        _buildTextField(emailEditingController, 'Email', Icons.email_rounded, r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$'),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 16),
        _buildConfirmPasswordField(),
        const SizedBox(height: 16),
        _buildTextField(mobileNumber, 'Mobile Number (e.g., 03XXXXXXXXX)', Icons.phone_android, r'^03\d{9}$'),
        const SizedBox(height: 16),
        _buildSecurityQuestionField(),
        const SizedBox(height: 16),
        _buildTextField(securityQuestionAnswerController, 'Security Question Answer', Icons.security_rounded, r'^[a-zA-Z0-9\s]+$'),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon, String pattern) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.deepPurple)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$hintText is required';
        } else if (!RegExp(pattern).hasMatch(value.trim())) {
          return 'Invalid $hintText';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordEditingController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.deepPurple),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.deepPurple)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: (value) => value != null && value.length >= 6 ? null : 'Password must be at least 6 characters',
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: confirmPasswordEditingController,
      obscureText: _obscuredconfirmpwd,
      decoration: InputDecoration(
        hintText: 'Confirm Password',
        prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
        suffixIcon: IconButton(
          icon: Icon(_obscuredconfirmpwd ? Icons.visibility_off : Icons.visibility, color: Colors.deepPurple),
          onPressed: () => setState(() => _obscuredconfirmpwd = !_obscuredconfirmpwd),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.deepPurple)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: (value) => value == passwordEditingController.text ? null : 'Passwords do not match',
    );
  }

  Widget _buildSecurityQuestionField() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: "Select Security Question", // You can add a label if needed
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        value: questions.isNotEmpty ? questions.first : null, // Set an initial value if list is not empty
        items: questions.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          // Update the selected security question
          setState(() {
            securityQuestions.text = value!;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Security Question is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: () => signUp(emailEditingController.text, passwordEditingController.text),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.purple,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Sign Up'),
    );
  }

  Widget _buildSignInPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('Already have an account? '),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const signInScreen())),
          child: const Text('Sign In here', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void signUp(String email, String password) async {
    if (_formSignUpKey.currentState!.validate()) {
      User user = User(
        username: firstNameEditingController.text,
        email: emailEditingController.text,
        password: passwordEditingController.text,
        usecurityQuestion: securityQuestions.text,
        uanswer: securityQuestionAnswerController.text,
        isAdmin: false,
        mobileNumber: mobileNumber.text,
        city: '',
        streetAddress: '',
        houseDetails: '',
        ucart: [],
        allergies: [],
        savedRecipes: [],
      );

      print("User to be signed up: ${user.toJson()}");

      try {
        int check = await Api.addUser(user);

        if (check == 205) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Email Taken"),
                content: const Text("Please enter another email"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        } else if (check == 200) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Sign Up Successful"),
                content: const Text("You can sign in using your email"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const signInScreen(),
                        ),
                      );
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        } else {
          print("Unknown response code from API: $check");
        }
      } catch (e) {
        print("Error during sign up: $e");
      }
    }
  }

  Future<void> fetchQuestions() async {
    List<securityQuestion> Question = await Api.fetchQuestions();
    setState(() {
      questions = Question.map((ing) => ing.question).toList();
    });
  }
}