import 'package:flutter/material.dart';
import 'package:fyp2/Admin%20CRUD/admin_page.dart';
import 'package:fyp2/colors.dart';
import 'package:fyp2/Authentication/signin_screen.dart';
import 'package:fyp2/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'API/api.dart';

class navBar extends StatefulWidget {
  const navBar({Key? key}) : super(key: key);

  @override
  State<navBar> createState() => _navBarState();
}


class _navBarState extends State<navBar> {

  bool? adminStatus = Api.adminStatus;

  @override
  void initState() {
    checkAdminStatus();
    super.initState();
  }
  void _logoutUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAdmin', false);
      await prefs.setBool('isLoggedIn', false);
      // Navigate to the login screen (replace SignInScreen with your actual login screen)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => signInScreen(),
        ),
      );
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  Future<void> checkAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getBool('isAdmin'));
    if(prefs.getBool('isAdmin')==true){
      adminStatus = true;
    }else{
      adminStatus = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    checkAdminStatus();
      return Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Profile Setting' , style: TextStyle(color : Colors.black)),
              leading: Icon(Icons.settings_outlined , color:primary[200],),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => userProfile(),
                    ));            },
            ),
            ListTile(
              title: const Text("Logout"),
              leading: Icon(Icons.logout_rounded, color: primary[200]),
              onTap: () {
                _logoutUser();
              },
            ),

          ],
        ),
      );
  }
}
