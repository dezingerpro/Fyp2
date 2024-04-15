import 'package:flutter/material.dart';
import 'package:fyp2/Main%20Page/search_page.dart';
import '../Cart+Checkout/cart.dart';
import '../Navigation/settings.dart';
import '../Navigation/user_profile.dart';
import '../grocery_screen.dart';
import '../landing_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onItemTapped(int index) {
    _previousIndex = _selectedIndex;
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleBackNavigation() {
    if (_navigatorKeys[_selectedIndex].currentState!.canPop()) {
      _navigatorKeys[_selectedIndex].currentState!.pop();
    } else if (_selectedIndex != _previousIndex) {
      setState(() {
        _selectedIndex = _previousIndex;
      });
    }
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[index],
        tabItem: index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        _handleBackNavigation();
      },
      child: Scaffold(
        body: Stack(
          children: List.generate(5, (index) => _buildOffstageNavigator(index)),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.food_bank), label: 'Recipes'),
            BottomNavigationBarItem(icon: Icon(Icons.production_quantity_limits), label: 'Grocery'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.blueGrey, // Set this to a visible color different from the background
          onTap: _onItemTapped,
          backgroundColor: Colors.white, // Make sure this contrasts well with the icon colors
          type: BottomNavigationBarType.fixed, // Ensures that all items are fixed and visible
        ),
      ),
    );
  }
}

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final int tabItem;

  const TabNavigator({required this.navigatorKey, required this.tabItem});

  @override
  Widget build(BuildContext context) {
    Widget child = Container(); // Default to an empty container

    switch (tabItem) {
      case 0:
        child = const MyHomePage(); // Replace with your HomePage widget
        break;
      case 1:
        child = const SearchPage();
        break;
      case 2:
        child = GroceryItemsPage();
        break;
      case 3:
        child = const CartPage(); // Replace with your RecipePage widget
        break;
      case 4:
        child = SettingsPage();  // Replace with your GroceryPage widget
        break;
    }

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => child,
        );
      },
    );
  }
}
