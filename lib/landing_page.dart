import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fyp2/grocery_screen.dart';
import 'package:fyp2/Recipes/all_recipe_screen.dart';
import 'package:fyp2/nav_bar.dart';
import 'package:fyp2/provider/cart_provider.dart';
import 'package:fyp2/search_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'API/api.dart';
import 'Models/ingredients_model.dart';
import 'Models/recipe_model.dart';
import 'Recipes/single_recipe_screen.dart';
import 'cart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Recipe> recipes = [];
  List<Recipe> filteredRecipes = [];
  TextEditingController searchController = TextEditingController();
  bool isFoodRecipesButtonPressed = false;
  bool isDeliveryButtonPressed = false;
  final List<String> myitems = [
    'assets/image01.png',
    'assets/image02.png',
    'assets/image03.png',
    'assets/image04.png',
    'assets/image05.png',
    'assets/images06.png'
  ];
  int myCurrentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  get focusNode => null;

  @override
  void initState() {
    super.initState();
    fetchRecipes();
    fetchGroceries();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Shop Grocery'),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => CartPage())),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, color: Colors.black),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Consumer<CartProvider>(
                      builder: (context, cart, child) {
                        return Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '${cart.totalItemCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to the SearchPage when the search bar is tapped
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const SearchPage()),
                      );
                    },
                    child: AbsorbPointer(
                      // Prevents the TextField from being selected
                      child: TextField(
                        controller: searchController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.only(top: 20.0, left: 20),
                          hintText: "Search for dishes",
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(
                              Icons.search,
                              color: Color(0xff7b7b7b),
                            ),
                          ),
                          filled: true,
                          fillColor: Color(0xfff7f7f7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(
                          color: Color(0xff707070),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      key: _scaffoldState,
      drawer: navBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.grey.shade100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 15),
                    //
                  ),
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        CarouselSlider(
                          options: CarouselOptions(
                            autoPlay: true,
                            height: 200,
                            autoPlayCurve: Curves.fastOutSlowIn,
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 800),
                            autoPlayInterval: const Duration(seconds: 5),
                            enlargeCenterPage: true,
                            aspectRatio: 2.0,
                            onPageChanged: (index, reason) {
                              setState(() {
                                myCurrentIndex = index;
                              });
                            },
                          ),
                          items: myitems.map((item) {
                            return Container(
                              width: double.infinity,
                              height: 200,
                              margin: EdgeInsets.symmetric(
                                  horizontal:
                                      5), // Add some margin between images
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(
                                        0.5), // You can customize the shadow color and opacity
                                    spreadRadius: 5,
                                    blurRadius: 10,
                                    offset: Offset(5,
                                        3), // Adjust the offset for the desired shadow direction
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  item,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        AnimatedSmoothIndicator(
                          activeIndex: myCurrentIndex,
                          count: myitems.length,
                          effect: WormEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            spacing: 10,
                            dotColor: Colors.black,
                            activeDotColor: Colors.purple.shade300,
                            paintStyle: PaintingStyle.fill,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Row with clickable tiles for "Food Recipes" and "Shop Grocery"
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Handle Food Recipes tile click action
                      // For example, navigate to FoodRecipesScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FoodRecipesScreen()),
                      ).then((_) {
                        fetchRecipes(); // Refresh your recipes list
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.43,
                        height: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.red),
                        child: Center(
                          child: Text(
                            "Food Recipes",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Handle Shop Grocery tile click action
                      // For example, navigate to ShopGroceryScreen
                      // Replace ShopGroceryScreen with your intended screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GroceryItemsPage()),
                      ).then((_) {
                        fetchRecipes(); // Refresh your recipes list
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.43,
                        height: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            "Shop Grocery",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Text(
                      "Recommended Recipes",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        filteredRecipes.length,
                        (index) => Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 4,
                          child: GestureDetector(
                            onTap: () {
                              MaterialPageRoute(
                                builder: (context) => RecipeIngredients(
                                  recipe: filteredRecipes[index],
                                ),
                              );
                            },
                            child: SizedBox(
                              height: 150,
                              width: 210,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 100,
                                    width: 210,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                        recipes[index].rimage,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          filteredRecipes[index].rname,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: RatingBar.builder(
                                          initialRating: filteredRecipes[index]
                                              .rratings
                                              .toDouble(),
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          ignoreGestures: true,
                                          itemCount: 5,
                                          itemSize: 20,
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          onRatingUpdate: (double value) {},
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, bottom: 20, right: 20.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 5.0, top: 20.0),
                      child: Text(
                        "Shop Grocery",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 200, // Adjust as needed
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: groceries.length,
                        itemBuilder: (context, index) {
                          final groceryItem = groceries[index];
                          return Container(
                            width: 180, // Adjust as needed
                            margin: EdgeInsets.only(
                                right: 10), // Space between cards
                            child: Card(
                              elevation: 6, // Adds shadow
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    20), // Clip image with card border radius
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize
                                      .min, // Avoids taking unnecessary space
                                  children: [
                                    Image.network(
                                      groceryItem.image,
                                      width: double
                                          .infinity, // Ensures image takes the full card width
                                      height: 100,
                                      fit: BoxFit
                                          .cover, // Covers the card area with the image
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        groceryItem.name,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple),
                                        overflow: TextOverflow
                                            .ellipsis, // Prevents text from overflowing
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: ElevatedButton.icon(
                                        icon: Icon(Icons.add_shopping_cart,
                                            size: 18),
                                        label: Text("Add to Cart",
                                            style: TextStyle(fontSize: 14)),
                                        onPressed: () async {
                                          _showAddToCartDialog(
                                              context, groceryItem);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors
                                              .deepPurple, // Button text color
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 80,
                alignment: Alignment.center,
                child: Text(
                  "REFER A FRIEND AND GET 10% OFF!",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Ingredient> groceries = [];

  Future<void> fetchGroceries() async {
    var data = await Api
        .fetchIngredients(); // This should return JSON data as List<Map<String, dynamic>>
    setState(() {
      groceries = data;
    });
  }

  Future<void> fetchRecipes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isGuest = prefs.getBool('isGuest') ?? true; // Default to true if not set

    var data = await Api.getRecipeAll();

    if (!isGuest) {
      var recommendedNames = await Api.fetchRecommendedRecipeNames();
      setState(() {
        // Map JSON data to Recipe models
        recipes = data.map<Recipe>((recipeJson) => Recipe.fromJson(recipeJson)).toList();
        // Filter recipes to only include recommended ones
        filteredRecipes = recipes.where((recipe) => recommendedNames.contains(recipe.rname)).toList();
      });
    } else {
      // For guest users, display any 10 recipes
      setState(() {
        // Map JSON data to Recipe models
        recipes = data.map<Recipe>((recipeJson) => Recipe.fromJson(recipeJson)).toList();
        // Randomly select 10 recipes to display
        filteredRecipes = (recipes..shuffle()).take(10).toList();
      });
    }
  }

  void _showAddToCartDialog(BuildContext context, Ingredient item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    int quantity =
        cartProvider.getItemQuantity(item.id); // Get the current quantity

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16),
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Select Quantity",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => setState(() {
                          if (quantity > 0)
                            quantity--; // Allow reducing to 0 for removal
                        }),
                      ),
                      Text(quantity.toString(), style: TextStyle(fontSize: 18)),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => setState(() {
                          quantity++;
                        }),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (quantity > 0) {
                        cartProvider.addItem(item,
                            quantity - cartProvider.getItemQuantity(item.id));
                      } else {
                        cartProvider.removeItem(item
                            .id); // Remove the item if quantity is reduced to 0
                      }
                      Navigator.pop(context);
                    },
                    child: Text('Update Cart'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
