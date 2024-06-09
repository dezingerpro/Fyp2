import 'package:flutter/material.dart';
import 'package:fyp2/Admin/add_recipe.dart';
import 'package:fyp2/Admin/delete_recipe.dart';
import 'package:fyp2/Admin/inventory_management.dart';
import 'package:fyp2/Admin/order_management.dart';
import 'package:fyp2/Admin/recipeManagement.dart';
import 'package:fyp2/Main%20Page/search_page.dart';
import 'package:fyp2/Admin/allrecipe_list_admin.dart';
import 'package:fyp2/Navigation/nav_bar.dart';

import '../API/api.dart';
import '../Authentication/signin_screen.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: MediaQuery.sizeOf(context).height*0.07),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0,bottom: 50),
              child: Text("Admin Dashboard",style: TextStyle(
                fontWeight: FontWeight.bold,fontSize: 32
              ),),
            ),
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Center(
                child: Padding(
                  padding:EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Card(
                            elevation: 5.0,
                            margin: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: (){
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                width: MediaQuery.of(context).size.width*0.92,
                                child: ListTile(
                                  leading: Icon(Icons.inventory_outlined,
                                      color: Theme.of(context).primaryColor,
                                      size: 40
                                  ),
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const recipeManagment(),
                                      ),
                                    );
                                  },
                                  title: const Text("Recipe Management"),
                                  subtitle: const Text('Manage Recipes'),
                                ),
                              ),
                            ),
                          ),
                          Card(
                            elevation: 5.0,
                            margin: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: (){
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                width: MediaQuery.of(context).size.width*0.92,
                                child: ListTile(
                                  leading: Icon(Icons.inventory_outlined,
                                      color: Theme.of(context).primaryColor,
                                      size: 40
                                  ),
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const IngredientListPage(),
                                      ),
                                    );
                                  },
                                  title: const Text("Inventory Management"),
                                  subtitle: const Text('Manage the inventory of groceries'),
                                ),
                              ),
                            ),
                          ),
                          Card(
                            elevation: 5,
                            margin: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const OrderManage(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                width: MediaQuery.of(context).size.width*0.92,
                                child: ListTile(
                                  leading: Icon(Icons.production_quantity_limits,
                                      color: Theme.of(context).primaryColor,
                                      size: 40
                                  ),
                                  title: const Text("Order Management"),
                                  subtitle: const Text('Manange your orders'),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _navigateToLoginPage(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: const EdgeInsets.all(10),
                                minimumSize: Size(double.infinity, 50), // Ensures the button covers the full width
                              ),
                              child: const Text("Logout",style: TextStyle(
                                color: Colors.white
                              ),),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLoginPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => signInScreen()),  // Replace with your sign-in screen
          (Route<dynamic> route) => false,
    );
  }

  Widget AllergyButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Api.reanalyzeRecipes(); // Call the function when the button is pressed
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.blue, // Set the text color to white
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding inside the button
        ),
        child: const Text('Analyze Recipes'),
      ),
    );
  }

  Widget CrudCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Widget destination,
  ) {
    return Card(
      elevation: 5,
      //margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => destination,
            ),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width*0.45, // Set your desired width
          height: MediaQuery.of(context).size.height*0.21, // Set your desired height
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
