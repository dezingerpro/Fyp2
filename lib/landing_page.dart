import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fyp2/grocery_screen.dart';
import 'package:fyp2/Recipes/all_recipe_screen.dart';
import 'package:fyp2/nav_bar.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'API/api.dart';
import 'Models/recipe_model.dart';
import 'Recipes/single_recipe_screen.dart';

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

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[200],
        title: const Text('Shabbirabad, Karachi'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0), // Adjust the padding as needed
            child: Icon(Icons.shopping_bag_outlined,color: Colors.black,),
          ),
          SizedBox(
            width: 10,
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                    child: Autocomplete<Recipe>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    return filteredRecipes.where((Recipe recipe) {
                      final nameLower = recipe.rname.toLowerCase();
                      final queryLower = textEditingValue.text.toLowerCase();

                      return nameLower.contains(queryLower);
                    });
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onChanged: (value) {
                        filterRecipes(value);
                      },
                      onSubmitted: (_) => onFieldSubmitted(),
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
                    );
                  },
                  displayStringForOption: (Recipe option) => option.rname,
                  optionsViewBuilder: (BuildContext context,
                      AutocompleteOnSelected<Recipe> onSelected,
                      Iterable<Recipe> options) {
                    return Container(
                      margin: EdgeInsets.all(0),
                      padding: EdgeInsets.only(right: 30),
                      child: Material(
                        elevation: 20,
                        child: ListView.separated(
                          physics: BouncingScrollPhysics(),
                          separatorBuilder: (context, index) {//<-- SEE HERE
                            return Divider(
                              height: 20,
                              thickness: 1.2,
                            );
                          },
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final option = options.elementAt(index);
                            return Container(
                              child: ListTile(
                                trailing: Icon(Icons.favorite_border),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(option.rimage), // Change this to the actual image property of your Recipe model
                                ),
                                title: Text(option.rname),
                                subtitle: Text("Recipe"),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecipeIngredients(
                                        recipe: filteredRecipes[index],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                )),
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
            SizedBox(height: 15,),
            // Row with clickable tiles for "Food Recipes" and "Shop Grocery"
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                  onTap: () {
              // Navigate to FoodRecipe screen when tapped
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FoodRecipesScreen()),
            );
    },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04),
        width: MediaQuery.of(context).size.width * 0.42,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5,
              offset: Offset(10, 1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              Text('Food Recipes', style: TextStyle(color: Colors.black, fontSize: 18, decoration: TextDecoration.underline),),
              Text('Recipes of Food That you Love', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w200),),
              // SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image(image: AssetImage('assets/recipes.png'), width: 130, height: 80,)
                ],
              )
            ],
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
                            builder: (context) => DeliveryScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                     child: Container(
                        width: MediaQuery.of(context).size.width * 0.42,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(color: Colors.grey, // Color of the shadow
                              blurRadius: 5, // Spread radius
                              offset: Offset(10, 1), // Offset of the shadow)
                            ),],
                        ),
                        child:Padding(padding: EdgeInsets.only(left: 10,right: 5), child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20,),
                            Text('Grocery',style: TextStyle(color: Colors.black,fontSize: 18,decoration: TextDecoration.underline),),
                            Text('Order Fresh Groceries',style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w200),),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image(image: AssetImage('assets/delivery.png'),width: 130,height: 100,),
                              ],
                            )


                          ] ,)
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
                        recipes.length,
                        (index) => Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                          ),
                          elevation: 4,
                          child: GestureDetector(
                            onTap: () {
                              MaterialPageRoute(
                                builder: (context) => RecipeIngredients(
                                  recipe: recipes[index],
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          recipes[index].rname,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: RatingBar.builder(
                                initialRating: recipes[index].rratings.toDouble(),
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                ignoreGestures: true,
                                itemCount: 5,
                                itemSize: 20,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ), onRatingUpdate: (double value) {
                              },
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
              padding: const EdgeInsets.only(left: 20.0, bottom: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Text(
                        "Shop Grocery",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (int i = 0; i <= 10; i++)
                              Container(
                                width: 100,
                                height: 100,
                                margin: EdgeInsets.only(right: 15),
                                decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(25)),
                              ),
                          ],
                        ))
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

  Future<void> fetchRecipes() async {
    var data = await Api.getRecipeAll();

    setState(() {
      recipes = data.map((recipeJson) {
        return Recipe.fromJson(recipeJson);
      }).toList();

      filteredRecipes = List.from(recipes);
    });
  }

  // Function to filter recipes based on the search query
  void filterRecipes(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredRecipes = List.from(recipes);
      });
      return;
    }

    setState(() {
      filteredRecipes = recipes.where((recipe) {
        final nameLower = recipe.rname.toLowerCase();
        final queryLower = query.toLowerCase();

        // Check if the recipe name contains the query
        if (nameLower.contains(queryLower)) {
          return true;
        }

        // Check if any part of the query matches the recipe name
        final queryParts = queryLower.split(' ');
        return queryParts.every((part) => nameLower.contains(part));
      }).toList();
    });
  }
}
