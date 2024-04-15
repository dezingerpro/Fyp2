import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fyp2/Authentication/signin_screen.dart';
import 'package:fyp2/Others/bottom_tabs.dart'; // Adjust the path as per your project structure
import 'package:fyp2/enter_ip.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash_Screen extends StatefulWidget {
  const Splash_Screen({super.key});

  @override
  State<Splash_Screen> createState() => _Splash_ScreenState();
}

class _Splash_ScreenState extends State<Splash_Screen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), navigateToNextScreen);
  }

  void navigateToNextScreen() async {

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => StartupScreen())); // Navigate to signInScreen if not logged in


  }

  // void navigateToNextScreen() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  //
  //   if (isLoggedIn) {
  //     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen())); // Navigate to MainScreen if logged in
  //   } else {
  //     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => signInScreen())); // Navigate to signInScreen if not logged in
  //   }
  //
  // }

  @override
  Widget build(BuildContext context) {
    // Assuming your logo's primary color is similar to #9C89B8; adjust as necessary.
    Color backgroundColor = Color(0xFF9C89B8);

    return Scaffold(
      body: Container(
        color: backgroundColor,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Image.asset('assets/logo.png', height: 300, width: 300),
              ),
            ),
            Text(
              "Food Savvy",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Adjust the color to match your logo or design
              ),
            ),
            Text(
              "Make cooking easier",
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.white70, // Adjust the color to complement the background
              ),
            ),
            SizedBox(height: 30), // Adjust spacing as needed
          ],
        ),
      ),
    );
  }
}
