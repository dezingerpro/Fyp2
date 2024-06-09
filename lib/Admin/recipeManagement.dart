import 'package:flutter/material.dart';
import 'package:fyp2/Admin/add_recipe.dart';
import 'package:fyp2/Admin/delete_recipe.dart';
import 'package:fyp2/Admin/inventory_management.dart';
import 'package:fyp2/Admin/order_management.dart';
import 'package:fyp2/Main%20Page/search_page.dart';
import 'package:fyp2/Admin/allrecipe_list_admin.dart';
import 'package:fyp2/Navigation/nav_bar.dart';

import '../API/api.dart';

class recipeManagment extends StatefulWidget {
  const recipeManagment({super.key});

  @override
  State<recipeManagment> createState() => _recipeManagmentState();
}

class _recipeManagmentState extends State<recipeManagment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: MediaQuery.sizeOf(context).height*0.07),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text("Recipe Dashboard",style: TextStyle(
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
                      AllergyButton(context),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CrudCard(
                            context,
                            "View",
                            "View all recipes",
                            Icons.visibility,
                            const SearchPage(),
                          ),
                          CrudCard(
                            context,
                            "Add",
                            "Add a new recipe",
                            Icons.add,
                            const AddRecipe(),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CrudCard(
                            context,
                            "Update",
                            "Update existing recipes",
                            Icons.update,
                            MyRecipeApp(),
                          ),
                          CrudCard(
                            context,
                            "Delete",
                            "Delete recipes",
                            Icons.delete,
                            DeleteRecipe(),
                          ),
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

  Widget AllergyButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Api.reanalyzeRecipes(); // Call the function when the button is pressed
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.purple, // Set the text color to white
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding inside the button
        ),
        child: const Text('Analyze Recipes for allergies'),
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
