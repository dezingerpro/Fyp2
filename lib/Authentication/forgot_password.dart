import 'package:flutter/material.dart';
import 'package:fyp2/Authentication/signin_screen.dart';
import '../API/api.dart';

class forgotPassword extends StatefulWidget {
  const forgotPassword({Key? key}) : super(key: key);

  @override
  State<forgotPassword> createState() => _forgotPasswordState();
}

class _forgotPasswordState extends State<forgotPassword> {
  TextEditingController emailController = TextEditingController();
  TextEditingController answerController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController questionController = TextEditingController();

  final _forgotPassword = GlobalKey<FormState>();
  final _securityQuestion = GlobalKey<FormState>();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //INPUT EMAIL
            Visibility(
              visible: true,
              child: Column(
                children: [
                  Text("Enter Email"),
                  TextFormField(
                    key: _forgotPassword,
                    controller: emailController,
                    enabled: !emailFound,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Email is required";
                      }
                      return null;
                    },
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            //INPUT SECURITY QUESTION
            Visibility(
              visible: _visibleQuestion,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(securityQuestion),
                  SizedBox(height: 10),
                  TextFormField(
                    key: _securityQuestion,
                    controller: questionController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Answer is required";
                      }
                      return null;
                    },
                  )
                ],
              ),
            ),
            Container(),
            SizedBox(height: 30),
            Visibility(
              visible: _newPass,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'New Password'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "New Password is required";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: _button1,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_done == true) {
                        forgotPasswordUpdate(
                            emailController.text, newPasswordController.text);
                      } else {
                        forgotPasswordCheck(emailController.text);
                      }
                    },
                    child: Text("Submit"),
                  ),
                ),
                Visibility(
                  visible: _button2,
                  child: ElevatedButton(
                    onPressed: () {
                      checkAnswer();
                    },
                    child: Text("Check Answer"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void checkAnswer() async {
    bool isAnswerCorrect =
        await Api.checkAnswer(emailController.text, questionController.text);

    if (isAnswerCorrect) {
      setState(() {
        _button2 = false;
        _done = true;
        _newPass = true;
        _button1 = true;
      });
    } else {
      // If the answer is incorrect, show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Incorrect Answer"),
            content: Text("The answer is incorrect. Please try again."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  void forgotPasswordCheck(String email) async {
    String uemail = emailController.text;
    var data = {"uemail": uemail};
    String checkStatus = await Api.forgotPassword(data);
    if (checkStatus != "invalid" && checkStatus != "error") {
      print("HI");
      setState(() {
        _visibleQuestion = true;
        securityQuestion = checkStatus;
        _button1 = false;
        _button2 = true;
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Email not Found"),
            content: Text("Invalid email. Please try again."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  void forgotPasswordUpdate(String email, String pass) {
    var data = {
      "uemail": email,
      "upass": pass,
    };
    Api.updatePassword(data);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Password Changed"),
          content: Text("Password successfully updated"),
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
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
