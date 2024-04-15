import 'package:flutter/material.dart';
import 'package:fyp2/Navigation/user_profile.dart';

import 'my_orders.dart';

class SettingsPage extends StatelessWidget {
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
            Text(
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
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserProfilePage(),
                          ))
                    ),
                    _settingsItem(
                      context,
                      icon: Icons.shopping_cart,
                      text: 'My Orders',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyOrdersPage(),
                          ))        ,
                    ),
                    _settingsItem(
                      context,
                      icon: Icons.bookmark,
                      text: 'Saved Recipes',
                      onTap: () => print('Saved Recipes'),
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
                      onTap: () => print('Help and Support'),
                    ),
                    _settingsItem(
                      context,
                      icon: Icons.info_outline,
                      text: 'About',
                      onTap: () => print('About'),
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
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
