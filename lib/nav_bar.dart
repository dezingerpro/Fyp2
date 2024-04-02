import 'package:flutter/material.dart';
import 'package:fyp2/Admin%20CRUD/admin_page.dart';
import 'package:fyp2/colors.dart';
import 'package:fyp2/Authentication/signin_screen.dart';
import 'package:fyp2/my_orders.dart';
import 'package:fyp2/provider/cart_provider.dart';
import 'package:fyp2/user_profile.dart';
import 'package:provider/provider.dart';
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
    super.initState();
  }
  void _logoutUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print("HELLO5555");
      await prefs.setBool('isAdmin', false);
      print("HELLO5555");
      await prefs.setBool('isLoggedIn', false);
      print("HELLO5555");
      String userId = prefs.getString('userId') as String;
      await prefs.setString('userId', '');
      print("HELLO5555");
      //await context.read<CartProvider>().saveCartToDatabase(userId);
      print("HELLO5555");// Navigate to the login screen (replace SignInScreen with your actual login screen)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => signInScreen(),
        ),
      );
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      builder: (context) => UserProfilePage(),
                    ));            },
            ),
            ListTile(
              title: const Text('My Orders' , style: TextStyle(color : Colors.black)),
              leading: Icon(Icons.settings_outlined , color:primary[200],),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyOrdersPage(),
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
