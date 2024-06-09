import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportFeedbackPage extends StatelessWidget {
  const SupportFeedbackPage({super.key});

  void _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@foodsavvy.com',
      query: 'subject=Support&Feedback&body=Your message here',
    );

    if (!await launchUrl(emailLaunchUri)) {
      throw Exception('Could not launch $emailLaunchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support & Feedback',style: TextStyle(
          fontWeight: FontWeight.bold,fontSize: 28
        ),),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'We are here to help you! If you have any questions, feedback, or need assistance, '
                  'please don\'t hesitate to contact us. Your input is valuable to us and helps us '
                  'improve our services.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _sendEmail,
                icon: Icon(Icons.email),
                label: Text('Email Us'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
