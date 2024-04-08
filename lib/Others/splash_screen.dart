import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fyp2/Authentication/signin_screen.dart';
import 'package:fyp2/Others/bottom_tabs.dart'; // Adjust the path as per your project structure
import 'package:shared_preferences/shared_preferences.dart';

class Splash_Screen extends StatefulWidget {
  const Splash_Screen({super.key});

  @override
  State<Splash_Screen> createState() => _Splash_ScreenState();
}

class _Splash_ScreenState extends State<Splash_Screen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isChefImageVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Trigger the image transition after 2 seconds
    Timer(const Duration(seconds: 2), () {
      setState(() {
        isChefImageVisible = false;
      });
      _controller.forward(); // Start the animation
    });

    // Check the login status and navigate accordingly after the animation is completed
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        final prefs = await SharedPreferences.getInstance();
        final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

        if (isLoggedIn) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen())); // Navigate to MainScreen if logged in
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => signInScreen())); // Navigate to signInScreen if not logged in
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/home.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: isChefImageVisible
                ? Image.asset('assets/chef.png', key: ValueKey('chef'), height: 300, width: 300)
                : Image.asset('assets/bike.png', key: ValueKey('bike'), height: 300, width: 300),
          ),
        ),
      ),
    );
  }
}
