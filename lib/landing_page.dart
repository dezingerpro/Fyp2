import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fyp2/provider/cart_provider.dart';
import 'package:fyp2/Main%20Page/search_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'API/api.dart';
import 'Models/ingredients_model.dart';
import 'Models/recipe_model.dart';

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
        backgroundColor: Theme.of(context).primaryColor, // Consider using a gradient or a vibrant solid color
        title: const Padding(
          padding: EdgeInsets.only(left: 5.0,top: 8),
          child: Text('Food Savvy', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: GestureDetector(
            onTap: () {
              // Trigger search or navigation
              Navigator.of(context).push(slideFromBottomTransition(const SearchPage()));
              //Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchPage()));
            },
            child: Container(
              width: double.infinity,
              height: 60,
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 10), // Fine-tuned padding
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.6)], // Subtle gradient effect
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white24), // Soft border to enhance the floating effect
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Icon(Icons.search, color: Color(0xff7b7b7b)),
                    ),
                    Expanded(
                      child: Text(
                        "Search for dishes",
                        style: TextStyle(
                          color: Color(0xff707070),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        elevation: 4, // Adjust elevation for depth
        shape: const RoundedRectangleBorder( // Rounded corners at the bottom of the AppBar
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),

      key: _scaffoldState,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.grey.shade100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 15),
                    //
                  ),
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(
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
                              margin: const EdgeInsets.symmetric(
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
                                    offset: const Offset(5,
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
                        const SizedBox(
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
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: CategoryCard(
                      title: "Food Recipes",
                      imagePath: 'assets/food-recipe.png',
                      onTap: () {
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: CategoryCard(
                      title: "Shop Grocery",
                      // startColor: Colors.green,
                      imagePath: 'assets/grocery-image.png',
                      // endColor: Colors.teal,
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => GroceryItemsPage()),
                        // ).then((_) {
                        //   fetchRecipes(); // Refresh your recipes list
                        // });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0,right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Text(
                      "Recommended Recipes",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple, // Adjust the color according to your theme
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        filteredRecipes.length,
                            (index) => RecipeCard(
                          recipeName: filteredRecipes[index].rname,
                          imageUrl: filteredRecipes[index].rimage,
                          rating: filteredRecipes[index].rratings.toDouble(),
                        ),
                      ),
                    ),
                  ),
                ],
              )
              ,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Shop Grocery",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 240, // Adjust based on content
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: groceries.length,
                      itemBuilder: (context, index) {
                        final groceryItem = groceries[index];
                        return GroceryItemCard(
                          name: groceryItem.name,
                          imageUrl: groceryItem.image,
                          onAddToCart: () {
                            _showAddToCartDialog(
                                context, groceryItem);
                          }, price: groceryItem.price.toString(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            ReferAFriendCTA(
              onReferPressed: () {
                // Implement what happens when the button is pressed
                // For example, showing a share dialog
                print('Refer a friend pressed');
              },
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
    bool isGuest =
        prefs.getBool('isGuest') ?? true; // Default to true if not set

    var data = await Api.getRecipeAll();

    if (!isGuest) {
      var recommendedNames = await Api.fetchRecommendedRecipeNames();
      setState(() {
        // Map JSON data to Recipe models
        recipes = data
            .map<Recipe>((recipeJson) => Recipe.fromJson(recipeJson))
            .toList();
        // Filter recipes to only include recommended ones
        filteredRecipes = recipes
            .where((recipe) => recommendedNames.contains(recipe.rname))
            .toList();
      });
    } else {
      // For guest users, display any 10 recipes
      setState(() {
        // Map JSON data to Recipe models
        recipes = data
            .map<Recipe>((recipeJson) => Recipe.fromJson(recipeJson))
            .toList();
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
              padding: const EdgeInsets.all(16),
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Select Quantity",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => setState(() {
                          if (quantity > 0) {
                            quantity--; // Allow reducing to 0 for removal
                          }
                        }),
                      ),
                      Text(quantity.toString(),
                          style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.add),
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
                      cartProvider.updateCart();
                      Navigator.pop(context);
                    },
                    child: const Text('Update Cart'),
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

class CategoryCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  final Color textColor;

  const CategoryCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.43,
        height: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 4), // Changes position of shadow
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3), // Darken the image
                    BlendMode.darken,
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReferAFriendCTA extends StatelessWidget {
  final VoidCallback onReferPressed;

  const ReferAFriendCTA({
    super.key,
    required this.onReferPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: Colors.deepPurple, // Adjust the color to fit your theme
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Invite Your Friends!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Share the joy and get 10% off for every friend who joins.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: onReferPressed,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.amber, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                ),
                child: const Text("Refer Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final String recipeName;
  final String imageUrl;
  final double rating;

  const RecipeCard({
    super.key,
    required this.recipeName,
    required this.imageUrl,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      height: 170,
      margin: const EdgeInsets.only(right: 10), // Add some space between the cards
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$rating',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                recipeName,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GroceryItemCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String price;
  final VoidCallback onAddToCart;

  const GroceryItemCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // Increased width
      // height: 180, // Decreased height
      margin: const EdgeInsets.only(right: 20,bottom: 30), // Increased spacing between cards
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Increased roundness
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18, // Slightly larger font for the name
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Rs $price", // Added "Rs" before the price
                  style: TextStyle(
                    fontSize: 18, // Slightly larger font for the price
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                ElevatedButton(
                  onPressed: onAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary, // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  child: const Text("Add to cart", style: TextStyle(fontSize: 14, color: Colors.white,)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

PageRouteBuilder<dynamic> slideFromBottomTransition(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0); // Start position off the screen (bottom)
      const end = Offset.zero; // End position (fills the screen)
      const curve = Curves.easeInOut; // An easing curve for smooth animation

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300), // Duration of the animation
  );
}



