import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Profile data initialization
  Map<String, String> profileData = {
    'Name': 'John Doe',
    'Email': 'johndoe@example.com',
    'Password': '******', // For demonstration
    'Mobile Number': '1234567890',
    'City': 'Springfield',
    'Street Address': '742 Evergreen Terrace',
    'House Name': 'The Simpsons House',
  };

  void _editProfileField(String title, String currentValue, ValueChanged<String> onUpdate) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Edit $title', style: TextStyle(color: Colors.deepPurple)),
        content: TextFormField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter $title',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel', style: TextStyle(color: Colors.deepPurple)),
          ),
          TextButton(
            onPressed: () {
              onUpdate(controller.text);
              Navigator.pop(context, 'Save');
            },
            child: const Text('Save', style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }

  Widget _profileField(String title, String value, ValueChanged<String> onUpdate) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        trailing: Icon(Icons.edit, color: Colors.deepPurple),
        onTap: () => _editProfileField(title, value, onUpdate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        children: profileData.entries.map((entry) {
          return _profileField(entry.key, entry.value, (newValue) {
            setState(() => profileData[entry.key] = newValue);
          });
        }).toList(),
      ),
    );
  }
}
