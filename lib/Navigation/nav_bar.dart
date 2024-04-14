import 'package:flutter/material.dart';
import 'package:fyp2/Others/colors.dart';
import 'package:fyp2/Authentication/signin_screen.dart';
import 'package:fyp2/Navigation/my_orders.dart';
import 'package:fyp2/Navigation/user_profile.dart';
import 'package:fyp2/provider/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/api.dart';
import '../main.dart';

class navBar extends StatefulWidget {
  const navBar({super.key});

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
                      builder: (context) => const UserProfilePage(),
                    ));            },
            ),
            ListTile(
              title: const Text('My Orders' , style: TextStyle(color : Colors.black)),
              leading: Icon(Icons.settings_outlined , color:primary[200],),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyOrdersPage(),
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
