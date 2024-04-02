import 'package:flutter/material.dart';
import 'package:fyp2/Admin%20CRUD/add_recipe.dart';
import 'package:fyp2/Admin%20CRUD/delete_recipe.dart';
import 'package:fyp2/Admin%20CRUD/order_management.dart';
import 'package:fyp2/Recipes/all_recipe_screen.dart';
import 'package:fyp2/Recipes/allrecipe_list_admin.dart';
import 'package:fyp2/nav_bar.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.purple,
          title: const Text('Karachi'), actions: const [
        SizedBox(
          width: 10,
        )
      ]),
      drawer: const navBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding:EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CrudCard(
                      context,
                      "View",
                      "View all recipes",
                      Icons.visibility,
                      const FoodRecipesScreen(),
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
                              builder: (context) => const orderManage(),
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
                  ],
                ),
              ],
            ),
          ),
        ),
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
