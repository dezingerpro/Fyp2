import 'package:flutter/material.dart';

class CustomNotification extends StatelessWidget {
  final String message;

  const CustomNotification({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  static void showNotification(BuildContext context, String message) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        right: 10,
        child: Material(
          color: Colors.transparent,
          child: CustomNotification(message: message),
        ),
      ),
    );

    // Insert the overlay entry
    Overlay.of(context).insert(overlayEntry);

    // Remove the overlay entry after 3 seconds
    Future.delayed(const Duration(seconds: 3)).then((_) {
      overlayEntry.remove();
    });
  }

}
