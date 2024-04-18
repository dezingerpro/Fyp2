import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fyp2/API/api.dart';
import 'package:fyp2/Models/recipe_model.dart';
import 'package:fyp2/Models/ingredients_model.dart';
import 'package:provider/provider.dart';
import '../Models/allergy_model.dart';
import '../Others/custom_text_fields.dart';
import '../Others/customer_drawer.dart';
import '../Recipes/recipe_cards.dart';
import '../provider/recipe_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  List<Recipe> recipes = [];
  List<Recipe> filteredRecipes = [];
  TextEditingController searchController = TextEditingController();
  List<String> selectedIngredients = [];
  String currentIngredient = '';
  List<String> ingredients = [];
  List<String> availableRecipeNames = [];
  final recipeIngredientNameController = TextEditingController();
  bool isLoading = true;
  late AnimationController _animationController;
  final debouncer =
      Debouncer(milliseconds: 500); // Adjust the milliseconds as needed
  bool _isSearching = false;
  double _dragStart = 0.0; // To track start position of the drag
  String? selectedAllergy; // Declare selectedAllergy variable
  List<Allergen> allergies = [];
  List<String> selectedAllergies = [];
  bool filterAllergens = false; // State to track checkbox status
  List<String> categories = [
    'All',
    'Pizza',
    'Burger',
    'Pasta',
    'Rice'
  ]; // List of categories
  int selectedIndex = 0; // Index of the currently selected tab

  @override
  void initState() {
    super.initState();
    fetchRecipes();
    fetchAllergies();
    fetchIngredients();
    _fetchUserDataAndInitialize();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  Future<void> _handleRefresh() async {
    fetchRecipes();
    fetchAllergies();
    fetchIngredients();
    _fetchUserDataAndInitialize();
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openDrawer() {
    _animationController.animateTo(1.0,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  void _closeDrawer() {
    _animationController.animateTo(0.0,
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    isLoading = recipeProvider.isLoading;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: _openDrawer,
                        ),
                        const Text(
                          "Search Recipes",
                          style: TextStyle(
                            fontSize: 32, // Large font size for emphasis
                            fontWeight:
                                FontWeight.bold, // Bold for visual impact
                            color: Colors.black, // Thematic color consistency
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            _handleRefresh();
                          },
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Search for recipe...',
                        hintText: "Enter a recipe name",
                        fillColor:
                            _isSearching ? Colors.lightBlue[50] : Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              15.0), // Subtle rounding of corners
                          borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.0), // Light grey outline
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.0), // Consistent with the overall border
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Colors.deepPurple,
                              width: 1.5), // Highlighted when focused
                        ),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.deepPurple),
                        suffixIcon: AnimatedOpacity(
                          opacity: searchController.text.isNotEmpty ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              searchController.clear();
                              _onSearchChanged('');
                            },
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        floatingLabelBehavior: FloatingLabelBehavior
                            .never, // Keeps the label as a placeholder
                        labelStyle: const TextStyle(color: Colors.grey),
                      ),
                    )),
                // Step 2: Implement a slider widget
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: CategoryTab(
                          category: categories[index],
                          isSelected: index == selectedIndex,
                          onTap: () {
                            setState(() {
                              selectedIndex = index; // Update selected index
                            });
                            // Call a method to filter recipes based on the selected category
                            filterRecipesByCategory(categories[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
                isLoading
                    ? Expanded(
                      child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          itemCount: 6, // Display 6 shimmer cards as placeholders
                          itemBuilder: (_, __) =>
                              RecipeCardShimmer(screenWidth: screenWidth),
                        ),
                    )
                    : Expanded(
                        child: RecipeListView(
                          recipes: filteredRecipes,
                          screenWidth: screenWidth,
                        ),
                      ),
              ],
            ),
            GestureDetector(
              onHorizontalDragStart: _onHorizontalDragStart,
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        _animationController.value * screenWidth - screenWidth,
                        0),
                    child: CustomDrawer(
                      onClose: _closeDrawer,
                      drawerContents: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),

                        CheckboxListTile(
                          title:
                              Text("Exclude recipes with selected allergens"),
                          value: filterAllergens,
                          onChanged: (bool? newValue) {
                            setState(() {
                              filterAllergens = newValue ?? false;
                              filterRecipes(
                                  searchController.text, availableRecipeNames);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        Divider(),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: CustomDropdownButtonFormField<String>(
                                value: selectedAllergy,
                                labelText: 'Select Allergy',
                                items: allergies.map((allergy) {
                                  return DropdownMenuItem<String>(
                                    value: allergy.allergen,
                                    child: Text(allergy.allergen),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedAllergy = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                                width:
                                    10), // Add some spacing between the dropdown and the button
                            ElevatedButton(
                              onPressed: _handleAddAllergy,
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                        // Display selected allergies
                        if (selectedAllergies.isNotEmpty)
                          Wrap(
                            spacing: 8.0,
                            children: selectedAllergies.map((allergy) {
                              return Chip(
                                label: Text(allergy),
                                deleteIcon: const Icon(Icons.close),
                                onDeleted: () {
                                  setState(() {
                                    selectedAllergies.remove(allergy);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        Divider(),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownSearch<String>(
                                items: ingredients,
                                dropdownBuilder: (context, selectedItem) {
                                  return Text(
                                    selectedItem ?? "Select Ingredient",
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  );
                                },
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    labelText: "Select Ingredient",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 15.0),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue.shade300),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      currentIngredient =
                                          value; // Update currentIngredient with the selected value
                                      recipeIngredientNameController.text =
                                          value;
                                    });
                                  }
                                },
                                popupProps: PopupProps.bottomSheet(
                                  isFilterOnline: true,
                                  showSearchBox: true,
                                  showSelectedItems: true,
                                  searchFieldProps: TextFieldProps(
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      labelText: "Search Ingredients",
                                      hintText: "Type to search...",
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    cursorColor: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (currentIngredient.isNotEmpty &&
                                    !selectedIngredients
                                        .contains(currentIngredient)) {
                                  setState(() {
                                    selectedIngredients.add(currentIngredient);
                                    currentIngredient = '';
                                    // Set loading state to true when the button is pressed
                                    isLoading = true;
                                  });

                                  try {
                                    // Fetch available recipe names based on the updated selected ingredients
                                    var newAvailableRecipeNames =
                                        await Api.sendIngredients(
                                            selectedIngredients);
                                    setState(() {
                                      availableRecipeNames =
                                          newAvailableRecipeNames;
                                      // Filter recipes to display based on the new list of available recipe names
                                      filterRecipes(searchController.text,
                                          availableRecipeNames);
                                      // Set loading state back to false when operation completes
                                      isLoading = false;
                                    });
                                    sortFilteredRecipes();
                                  } catch (error) {
                                    // Ensure loading state is set to false even if there's an error
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 8.0,
                          children: selectedIngredients.map((ingredient) {
                            return Chip(
                              label: Text(ingredient),
                              deleteIcon: const Icon(Icons.close),
                              onDeleted: () {
                                setState(() {
                                  selectedIngredients.remove(ingredient);
                                  isLoading =
                                      true; // Start loading indicator when deleting begins
                                });
                                Api.sendIngredients(selectedIngredients)
                                    .then((newAvailableRecipeNames) {
                                  setState(() {
                                    availableRecipeNames =
                                        newAvailableRecipeNames;
                                    // Filter recipes to display based on the new list of available recipe names
                                    filterRecipes(searchController.text,
                                        availableRecipeNames);
                                    isLoading =
                                        false; // Stop loading indicator once data is fetched and processed
                                  });
                                }).catchError((error) {
                                  // Always handle potential errors and stop loading
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStart = details.globalPosition.dx;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    double delta = details.globalPosition.dx - _dragStart;
    _dragStart = details.globalPosition.dx;
    double dragPercent = delta / MediaQuery.of(context).size.width;
    _animationController.value += dragPercent;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final double flingVelocity = details.primaryVelocity ?? 0;
    if (flingVelocity.abs() > 365.0) {
      double visualVelocity = flingVelocity / MediaQuery.of(context).size.width;
      _animationController.fling(velocity: visualVelocity);
    } else if (_animationController.value < 0.5) {
      _closeDrawer();
    } else {
      _openDrawer();
    }
  }

  void filterRecipesByCategory(String category) {
    // Filter the recipes based on the selected category
    if (category == "All") {
      filteredRecipes = List.from(recipes);
    } else {
      filteredRecipes =
          recipes.where((recipe) => recipe.rtype == category).toList();
    }

    Provider.of<RecipeProvider>(context, listen: false)
        .updateRecipes(filteredRecipes);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    debouncer.run(() {
      filterRecipes(query, availableRecipeNames);
    });
  }

  void sortFilteredRecipes() {
    setState(() {
      filteredRecipes.sort((a, b) => availableRecipeNames
          .indexOf(a.rname)
          .compareTo(availableRecipeNames.indexOf(b.rname)));
    });
  }

  Future<void> fetchRecipes() async {
    //var data = await Api.getRecipeAll();
      recipes = await Provider.of<RecipeProvider>(context, listen: false)
          .fetchRecipes();
      filteredRecipes = List.from(recipes);
    //Provider.of<RecipeProvider>(context, listen: false)
     //   .updateRecipes(filteredRecipes);
    availableRecipeNames =
        filteredRecipes.map((recipe) => recipe.rname).toList();
  }

  Future<void> fetchIngredients() async {
    List<Ingredient> Ing = await Api.fetchIngredients();
    setState(() {
      ingredients = Ing.map((ing) => ing.name).toList();
    });
  }

  bool containsAllergens(Recipe recipe, List<String> selectedAllergies) {
    return recipe.allergens
        .any((allergen) => selectedAllergies.contains(allergen));
  }

  void filterRecipes(String query, List<String> availableRecipes) {
    // First, filter the recipes to include only those in the availableRecipes list
    var recipesToShow = recipes
        .where((recipe) => availableRecipes.contains(recipe.rname))
        .toList();

    // Conditionally filter out recipes containing selected allergens
    // if (filterAllergens) {
    //   recipesToShow = recipesToShow
    //       .where((recipe) => !containsAllergens(recipe, selectedAllergies))
    //       .toList();
    // }

    // Conditionally filter out recipes containing selected allergens
    if (filterAllergens) {
      List<Recipe> allergenContainingRecipes = recipesToShow
          .where((recipe) => containsAllergens(recipe, selectedAllergies))
          .toList();

      recipesToShow = recipesToShow
          .where((recipe) => !containsAllergens(recipe, selectedAllergies))
          .toList();

      // Print information about recipes with allergens
      if (allergenContainingRecipes.isNotEmpty) {
        print(
            'Found ${allergenContainingRecipes.length} recipes containing selected allergens.');
      } else {
        print('No recipes found containing selected allergens.');
      }
    }

    // Next, filter based on the query if it's not empty
    filteredRecipes = query.isEmpty
        ? recipesToShow
        : recipesToShow
            .where((recipe) =>
                recipe.rname.toLowerCase().contains(query.toLowerCase()))
            .toList();

    Provider.of<RecipeProvider>(context, listen: false)
        .updateRecipes(filteredRecipes);
  }

  void _fetchUserDataAndInitialize() async {
    var userData = await Api
        .fetchUser(); // Assume this returns a Map<String, dynamic> of user data
    if (userData != null) {
      setState(() {
        // Initialize selectedAllergies from userData, ensuring it handles the case where allergies may not exist
        selectedAllergies = List<String>.from(userData['allergies'] ?? []);
      });
    }
  }

  void _handleAddAllergy() {
    if (selectedAllergy != null &&
        !selectedAllergies.contains(selectedAllergy)) {
      setState(() {
        selectedAllergies.add(selectedAllergy!);
      });
    }
  }

  void fetchAllergies() async {
    allergies = await Api.fetchAllergens();
  }
}

class CategoryTab extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryTab({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
