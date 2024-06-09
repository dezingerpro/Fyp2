import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fyp2/Others/Splash_Screen.dart';
import 'package:fyp2/Others/colors.dart';
import 'package:fyp2/provider/cart_provider.dart';
import 'package:fyp2/provider/grocery_provider.dart'; // Import your GroceryProvider
import 'package:fyp2/provider/recipe_provider.dart';
import 'package:provider/provider.dart';

import 'API/api.dart';
import 'Others/bottom_tabs.dart';
import 'SQFLite DB/database_sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  await FlutterBackgroundService().configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  // No operation performed, but signaling successful completion
  return Future.value(true);
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
    service.on('downloadRecipe').listen((event) async {
      bool success = await downloadAndSaveRecipe(event!['recipeId']);
      service.invoke(
        'notifyUser',
        {
          'title': 'Recipe Download',
          'body': success ? 'Download completed!' : 'Download failed.',
        },
      );
    });
}

Future<bool> downloadAndSaveRecipe(String recipeId) async {
  try {
    Api api = Api();
    Map<String, dynamic> recipeData = await api.fetchRecipeById(recipeId);
    DatabaseHelper db = DatabaseHelper();

    if (recipeData.isNotEmpty) {
      List<Map<String, dynamic>> ingredients = [];
      List<String> allergens = [];
      List<String> instructions = [];

      // Extract ingredients, allergens, and instructions if they exist in the fetched data
      if (recipeData['ringredients'] != null) {
        ingredients = (recipeData['ringredients'] as List)
            .map((ingredient) => {
          'ingredientName': ingredient['ingredientName'],
          'quantity': ingredient['quantity'],
        })
            .toList();
      }
      if (recipeData['allergens'] != null) {
        allergens = List<String>.from(recipeData['allergens']);
      }
      if (recipeData['rinstructions'] != null) {
        instructions = List<String>.from(recipeData['rinstructions']);
      }

      // Prepare the main recipe data for insertion
      Map<String, dynamic> recipe = {
        'id': recipeData['_id'],
        'rname': recipeData['rname'],
        'rmainingredient': recipeData['rmainingredient'],
        'rratings': recipeData['rratings'],
        'rimage': recipeData['rimage'],
        'rlink': recipeData['rlink'],
        'rtype': recipeData['rtype'],
      };

      // Insert the recipe and its components into the database
      bool inserted = await db.insertRecipe(recipe, ingredients, allergens, instructions);
      return inserted;
    } else {
      print("No recipe data found");
    }
  } catch (error) {
    print("Failed to download and save recipe: $error");
    return false;
  }
  return false;
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
        ChangeNotifierProvider(create: (context) => RecipeProvider()), // Add your GroceryProvider
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: primary,
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: _CustomPageTransitionBuilder(),
              TargetPlatform.iOS: _CustomPageTransitionBuilder(),
            },
          ), // Ensure 'primary' is defined or use Colors.blue
        ),
        navigatorKey: navigatorKey,
        home: const Splash_Screen(), // Set Splash_Screen as the home screen
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class _CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    var begin = const Offset(1.0, 0.0);
    var end = Offset.zero;
    var curve = Curves.easeInOut;
    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }
}
