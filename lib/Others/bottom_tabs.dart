import 'package:flutter/material.dart';
import 'package:fyp2/Main%20Page/search_page.dart';
import '../Cart/cart.dart';
import '../Navigation/settings.dart';
import '../grocery_screen.dart';
import '../Main Page/landing_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  PageController _pageController = PageController();
  static MainScreenState? instance;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    instance = this;
  }

  @override
  void dispose() {
    instance = null;
    _pageController.dispose();
    super.dispose();
  }

  void resetAndSwitchTab(int tabIndex) {
    // Reset the navigation stack of the current tab
    _navigatorKeys[_selectedIndex].currentState!.popUntil((route) => route.isFirst);
    // Switch to the specified tab
    selectTab(tabIndex);
  }

  void selectTab(int index) {
    if (index != _selectedIndex) {
      _onItemTapped(index);
    }
  }

  void _onItemTapped(int index) {
    _previousIndex = _selectedIndex;
    setState(() {
      _selectedIndex = index;
    });

    if ((_selectedIndex - _previousIndex).abs() > 1) {
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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

  void switchToHomeAndResetCart() {
    // Reset cart navigator
    _navigatorKeys[3].currentState!.popUntil((route) => route.isFirst);

    // Switch to home tab
    setState(() {
      _selectedIndex = 0;
    });
    _pageController.jumpToPage(0);
  }

  Widget _buildPageView() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      children: List.generate(5, (index) => TabNavigator(
        navigatorKey: _navigatorKeys[index],
        tabItem: index,
      )),
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
        body: _buildPageView(),
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
          unselectedItemColor: Colors.blueGrey,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
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
