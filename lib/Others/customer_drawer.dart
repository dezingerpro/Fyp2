import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback onClose;
  final List<Widget> drawerContents;

  const CustomDrawer({
    Key? key,
    required this.onClose,
    required this.drawerContents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8, // Drawer width
        color: Colors.white,
        child: Column(
          children: drawerContents,
        ),
      ),
    );
  }
}