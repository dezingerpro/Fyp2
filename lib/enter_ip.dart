import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'API/api.dart';
import 'Authentication/signin_screen.dart';
import 'Others/bottom_tabs.dart';

class StartupScreen extends StatefulWidget {
  @override
  _StartupScreenState createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  final TextEditingController _ipController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedIP();
  }

  void _loadSavedIP() async {
    final prefs = await SharedPreferences.getInstance();
    String savedIP = prefs.getString('serverIP') ?? '';
    _ipController.text = savedIP;
  }

  void _saveIPAndProceed() async {
    setState(() {
      _isSaving = true;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('serverIP', _ipController.text);
    Api.initIp(_ipController.text);
    // Navigate to your main application screen or wherever appropriate
    navigateToNextScreen();
  }

  void navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen())); // Navigate to MainScreen if logged in
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => signInScreen())); // Navigate to signInScreen if not logged in
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Server IP"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: "Server IP Address",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveIPAndProceed,
              child: Text("Save and Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
