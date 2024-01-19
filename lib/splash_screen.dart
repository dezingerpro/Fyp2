import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fyp2/Authentication/signin_screen.dart';
import 'package:fyp2/landing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash_Screen extends StatefulWidget {
  const Splash_Screen({super.key});

  @override
  State<Splash_Screen> createState() => _Splash_ScreenState();
}

class _Splash_ScreenState extends State<Splash_Screen>
    with SingleTickerProviderStateMixin {
  bool isChefImageVisible = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    // After 3 seconds, trigger the image transition
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isChefImageVisible = false;
        _controller.forward(); // Start the animation
      });

      _controller.addStatusListener((status) async {
        if (status == AnimationStatus.completed) {

          final prefs = await SharedPreferences.getInstance();
          if(prefs.getBool('isLoggedIn')==true){
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (BuildContext context) => MyHomePage()),
            );
          }
          else{
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (BuildContext context) => signInScreen()),
            );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.transparent,
      body:
      Center(
        child: Container(

          decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/home.png',),
                fit: BoxFit.cover,
              )
          ),
          width: double.infinity,
          height: double.infinity,
          // width: double.infinity,
          // height: double.infinity,
          // decoration: BoxDecoration(
          //   gradient: LinearGradient(
          //     begin: Alignment.topRight,
          //     end: Alignment.bottomLeft,
          //     colors: [Color(0xFFBAE9E6),
          //       Color(0xFF8BC6A3)],
          //   ),
          // ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Column(
                children: [
                  AnimatedSwitcher(
                    duration: Duration(seconds: 1),
                    child: isChefImageVisible
                        ? SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0.0, 0.0),
                        end: Offset(-0.08, 0.0),
                      ).animate(CurvedAnimation(
                        curve: Curves.easeOut,
                        parent: _controller,
                      )),
                      child: Image.asset(
                        'assets/chef.png',
                        height: 300,
                        width: 300,
                        key: Key('1'),
                      ),
                    )
                        : SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(-1.0, -0.1),
                        end: Offset(-0.08, -0.1),
                      ).animate(CurvedAnimation(
                        curve: Curves.easeOut,
                        parent: _controller,
                      )),
                      child: Image.asset(
                        'assets/bike.png',
                        height: 300,
                        width: 300,
                        key: Key('2'),
                      ),
                    ),
                  ),
                  // ShaderMask(
                  //   shaderCallback: (Rect bounds) {
                  //     return LinearGradient(
                  //       colors: [Color(0xFF117A83), Color(0xFF5C1B8D)],
                  //       begin: Alignment.topRight,
                  //       end: Alignment.bottomLeft,
                  //       tileMode: TileMode.mirror,
                  //     ).createShader(bounds);
                  //   },
                  //   child: Text(
                  //     'Food Savvy',
                  //     textAlign: TextAlign.center,
                  //     style: TextStyle(
                  //       fontFamily: 'PlaypenSans',
                  //       fontSize: 50,
                  //       fontWeight: FontWeight.bold,
                  //       wordSpacing: 7,
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  // ),
                  // Text(
                  //   'Changing The Way You Cook',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 12,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
