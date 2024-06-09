import 'package:flutter/material.dart';
import 'package:fyp2/Navigation/about_page.dart';
import 'package:fyp2/Navigation/support_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fyp2/Navigation/user_profile.dart';
import 'package:fyp2/Recipes/saved_recipe_screen.dart';
import '../Authentication/signin_screen.dart';
import 'my_orders.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isGuest = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isGuest = prefs.getBool('isGuest') ?? true;
    });
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Login Required"),
          content: const Text("You need to log in to access the profile page."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToLoginPage(context);
              },
              child: const Text("Login / Sign Up"),
            ),
          ],
        );
      },
    );
  }

  void _navigateToLoginPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => signInScreen()),  // Replace with your sign-in screen
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.04,
            left: 16,
            right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Settings',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Expanded(
              child: ListView(
                children: ListTile.divideTiles(
                  context: context,
                  tiles: [
                    _settingsItem(
                      context,
                      icon: Icons.account_circle,
                      text: 'Profile',
                      onTap: () {
                        if (isGuest) {
                          _showLoginDialog(context);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserProfilePage(),
                            ),
                          );
                        }
                      },
                    ),
                    _settingsItem(
                      context,
                      icon: Icons.shopping_cart,
                      text: 'My Orders',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyOrdersPage(),
                        ),
                      ),
                    ),
                    _settingsItem(
                      context,
                      icon: Icons.bookmark,
                      text: 'Saved Recipes',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RecipeScreen()),
                      ),
                    ),
                    _settingsItem(
                      context,
                      icon: Icons.settings,
                      text: 'Preferences',
                      onTap: () => print('Preferences'),
                    ),
                    _settingsItem(
                      context,
                      icon: Icons.help_outline,
                      text: 'Support & Feedback',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SupportFeedbackPage()),
                      ),
                    ),
                    _settingsItem(
                      context,
                      icon: Icons.info_outline,
                      text: 'About',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutPage()),
                      ),
                    ),
                  ],
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsItem(BuildContext context,
      {required IconData icon,
        required String text,
        required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
