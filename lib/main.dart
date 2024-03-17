import 'package:flutter/material.dart';
import 'package:fyp2/Splash_Screen.dart';
import 'package:fyp2/colors.dart';
import 'package:fyp2/provider/cart_provider.dart';
import 'package:fyp2/provider/grocery_provider.dart'; // Import your GroceryProvider
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => GroceryProvider()), // Add your GroceryProvider
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: primary, // Ensure 'primary' is defined or use Colors.blue
        ),
        home: Splash_Screen(), // Make sure Splash_Screen is correctly implemented
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
