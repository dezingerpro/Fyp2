import 'package:flutter/material.dart';
import 'package:fyp2/Others/Splash_Screen.dart';
import 'package:fyp2/Others/colors.dart';
import 'package:fyp2/provider/cart_provider.dart';
import 'package:fyp2/provider/grocery_provider.dart'; // Import your GroceryProvider
import 'package:fyp2/provider/recipe_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
   const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => GroceryProvider()),
    ChangeNotifierProvider(create: (context) => RecipeProvider()),// Add your GroceryProvider
],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: primary, // Ensure 'primary' is defined or use Colors.blue
        ),
        navigatorKey: navigatorKey,
        home: const Splash_Screen(), // Make sure Splash_Screen is correctly implemented
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
