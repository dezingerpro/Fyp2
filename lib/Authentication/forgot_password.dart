import 'package:flutter/material.dart';
import 'package:fyp2/Authentication/signin_screen.dart';
import '../API/api.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  TextEditingController answerController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController questionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool emailFound = false;
  String securityQuestion = "";
  bool showNewPasswordField = false;
  bool showCheckAnswerButton = true;
  bool _visibleQuestion = false;
  bool _button1 = true;
  bool _button2 = false;
  bool _done = false;
  bool _newPass = false;
  String errorMessage = '';

  @override
  void dispose() {
    emailController.dispose();
    answerController.dispose();
    newPasswordController.dispose();
    questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Forgot Password",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Error Message
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  // INPUT EMAIL
                  Column(
                    children: [
                      const Text(
                        "Enter Email",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailController,
                        enabled: !emailFound,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.deepPurple),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Email is required";
                          } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$').hasMatch(value)) {
                            return "Invalid email format";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // INPUT SECURITY QUESTION
                  AnimatedOpacity(
                    opacity: _visibleQuestion ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Visibility(
                      visible: _visibleQuestion,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            securityQuestion,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: questionController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.question_answer, color: Colors.deepPurple),
                              hintText: 'Answer',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.deepPurple),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Answer is required";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // NEW PASSWORD FIELD
                  AnimatedOpacity(
                    opacity: _newPass ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Visibility(
                      visible: _newPass,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: newPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                              hintText: 'New Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.deepPurple),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "New Password is required";
                              } else if (value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                        visible: _button1,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                errorMessage = '';
                              });
                              if (_done) {
                                forgotPasswordUpdate(emailController.text, newPasswordController.text);
                              } else {
                                forgotPasswordCheck(emailController.text);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text("Submit"),
                        ),
                      ),
                      Visibility(
                        visible: _button2,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                errorMessage = '';
                              });
                              checkAnswer();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text("Check Answer"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void checkAnswer() async {
    try {
      bool isAnswerCorrect = await Api.checkAnswer(emailController.text, questionController.text);
      print(isAnswerCorrect);
      if (!mounted) return;
      if (isAnswerCorrect) {
        setState(() {
          _button2 = false;
          _done = true;
          _newPass = true;
          _button1 = true;
          errorMessage = '';
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Incorrect Answer"),
              content: const Text("The answer is incorrect. Please try again."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text(e.toString()),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void forgotPasswordCheck(String email) async {
    try {
      String uemail = emailController.text;
      var data = {"uemail": uemail};
      String checkStatus = await Api.forgotPassword(data);
      if (!mounted) return;

      if (checkStatus != "invalid" && checkStatus != "error") {
        setState(() {
          _visibleQuestion = true;
          securityQuestion = checkStatus;
          _button1 = false;
          _button2 = true;
          errorMessage = '';
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Email not Found"),
              content: const Text("Invalid email. Please try again."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text(e.toString()),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void forgotPasswordUpdate(String email, String pass) async {
    try {
      var data = {
        "uemail": email,
        "upass": pass,
      };
      await Api.updatePassword(data);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Password Changed"),
            content: const Text("Password successfully updated"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => signInScreen(),
                    ),
                  );
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text(e.toString()),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }
}