import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../API/api.dart';
import '../Models/ingredients_model.dart';
import '../Models/ratings_model.dart';
import '../Models/recipe_model.dart';
import '../provider/cart_provider.dart'; // Adjust the import path as necessary

class RecipeIngredients extends StatefulWidget {
  final Recipe recipe;
  final List<String> selectedIngredients;

  const RecipeIngredients({super.key, required this.recipe,required this.selectedIngredients});

  @override
  _RecipeIngredientsState createState() => _RecipeIngredientsState();
}

class _RecipeIngredientsState extends State<RecipeIngredients>
    with SingleTickerProviderStateMixin {
  late YoutubePlayerController _youtubePlayerController;
  final _reviewController = TextEditingController();
  List<Rating> _ratings = [];
  bool _isLoading = true;
  double _userRating = 0;
  late TabController _tabController;

  @override
  void initState() {
    print(widget.recipe.ringredients.first['quantity']);
    print(widget.recipe.ringredients.first['ingredientName']);
    super.initState();
    _fetchRatings();
    _tabController = TabController(length: 3, vsync: this);
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId('bFpfqGT5u-k')!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  Future<void> _fetchRatings() async {
    try {
      List<Rating> ratingsList =
          await Api.fetchRatingsForRecipe(widget.recipe.id);
      setState(() {
        _ratings = ratingsList;
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to fetch ratings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _youtubePlayerController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') as String;
    // Submit the rating and review to your API
    final success = await Api.submitRecipeRating(
      userId: userId,
      recipeId: widget.recipe.id,
      rating: _userRating,
      review: _reviewController.text,
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted successfully')));
      _reviewController.clear(); // Clear the review text field
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to submit rating')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 250.0,
              leading: const SizedBox.shrink(),
              floating: false,
              pinned: false,
              backgroundColor:
                  Colors.transparent, // Make AppBar background transparent
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  var top = constraints.biggest.height;
                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(8.0), // Padding around the image
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    20), // Rounded corners
                                image: DecorationImage(
                                  image: NetworkImage(widget.recipe.rimage),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: top > 70
                              ? 30
                              : 10, // Adjust this value to position the button correctly (dynamic based on AppBar height)
                          left: 20,
                          child: CircleAvatar(
                            // Circle background for the icon
                            backgroundColor: Colors.white, // White circle
                            radius: 20, // Size of the circle
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.black), // Black arrow icon
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ];
        },
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.recipe
                        .rname, // Assuming the recipe name is stored here
                    style: const TextStyle(
                      fontSize: 24, // Large text size for prominence
                      fontWeight: FontWeight.bold, // Bold for emphasis
                      color: Colors
                          .deepPurple, // Modern color choice that matches the icon color
                    ),
                  ),
                ),
                const SizedBox(
                    height: 20), // Spacing between the InfoCard and the title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    const InfoCard(
                        icon: Icons.timer,
                        label: '45 mins',
                        tooltip: 'Prep Time'),
                    const InfoCard(
                        icon: Icons.star_rate, label: '4.5', tooltip: 'Rating'),
                    InfoCard(
                        icon: Icons.download_for_offline_outlined,
                        label: 'Save',
                        isButton: true,
                        onTap: () {
                          final service = FlutterBackgroundService();
                          service.invoke(
                              'downloadRecipe', {'recipeId': widget.recipe.id});
                          print(
                              'Like tapped'); // Implement your like functionality
                        }),
                  ],
                ),
                const SizedBox(
                    height: 10), // Spacing between the InfoCard and the title
                DefaultTabController(
                  length: 3,
                  child: Expanded(
                    child: Column(
                      children: [
                        const TabBar(
                          labelColor: Colors.deepPurple,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: 'Ingredients'),
                            Tab(text: 'Details'),
                            Tab(text: 'Reviews'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildIngredientsTab(),
                              _buildDetailsTab(),
                              _buildReviewsTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsTab() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.recipe.ringredients.length,
          itemBuilder: (context, index) {
            final ingredient = widget.recipe.ringredients[index];
            bool hasImage = ingredient['image'] != null && ingredient['image'].isNotEmpty;

            // Check if the ingredient is in the selectedIngredients list
            bool isSelected = widget.selectedIngredients.contains(ingredient['ingredientName']);

            // Apply different background colors based on whether the ingredient is selected or not
            Color backgroundColor = isSelected ? Colors.grey.shade200 : Colors.white;

            // Text style for ingredient names
            TextStyle nameStyle = const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            );

            return Container(
              decoration: BoxDecoration(
                color: backgroundColor, // Set background color conditionally
                borderRadius: BorderRadius.circular(10), // Rounded corners
                border: Border.all(
                  color: Colors.grey.shade300, // Subtle border color
                  width: 1,
                ),
              ),
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  if (hasImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        ingredient['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      radius: 25,
                      child: const Icon(Icons.info_outline, color: Colors.black),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ingredient['ingredientName'],
                          style: nameStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (ingredient['secondaryName'].isNotEmpty)
                          Text(
                            ingredient['secondaryName'],
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          ingredient['extra'],
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        ingredient['quantity'],
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ingredient['qtytype'],
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart, color: Colors.deepPurple),
                    onPressed: () async {
                      Ingredient? detailedIngredient = await Api.fetchIngredientDetails(ingredient['ingredientName']);
                      if (detailedIngredient != null) {
                        _showQuantityDialog(context, detailedIngredient, cartProvider);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error fetching ingredient details'))
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }




  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Description:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            //Text(widget.recipe.description ?? "No description available.", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            // Text("Cooking Time: ${widget.recipe.cookingTime} minutes", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            //Text("Servings: ${widget.recipe.servings}", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Text('Rate and Review:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(
                  horizontal: 8.0), // Increased spacing for a cleaner look
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _userRating = rating;
                });
              },
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Leave a review (Optional)',
                hintStyle:
                    TextStyle(color: Colors.grey[500]), // Lighter hint text
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Rounded corners for the field
                  borderSide: BorderSide.none, // No border
                ),
                filled: true,
                fillColor: Colors.grey[200], // Light grey fill for subtlety
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _submitRating,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.deepPurple, // Text color
                  elevation: 2, // Subtle shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded edges
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10), // Padding for a better shape
                ),
                child: const Text('Submit Rating'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ratings.isEmpty
              ? const Text("No reviews yet.")
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _ratings.length,
                  itemBuilder: (context, index) {
                    final rating = _ratings[index];
                    return RatingCard(
                      rating: rating.rating,
                      review: rating.review,
                      userName: rating.user.uname,
                    );
                  },
                ),
    ));
  }

  void _showQuantityDialog(
      BuildContext context, Ingredient item, CartProvider cartProvider) {
    int currentQuantity = cartProvider.items.containsKey(item.id)
        ? cartProvider.items[item.id]!.quantity
        : 0;
    int quantity = currentQuantity;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: currentQuantity > 0
                  ? 250
                  : 200, // Adjust height based on current quantity
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Adjust Quantity",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => setState(
                            () => quantity = quantity > 0 ? quantity - 1 : 0),
                      ),
                      Text(quantity.toString(), style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => quantity++),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    child: const Text('Confirm'),
                    onPressed: () {
                      if (quantity == 0) {
                        cartProvider.removeItem(item.id);
                      } else {
                        cartProvider.addItem(item, quantity - currentQuantity);
                      }
                      Navigator.pop(context); // Close the bottom sheet
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Rating>> getRatings() async {
    var listoflol = await Api.fetchRatingsForRecipe(widget.recipe.id);
    return listoflol;
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final bool isButton;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.icon,
    required this.label,
    this.tooltip = '',
    this.isButton = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Reduced elevation for a subtler shadow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isButton ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon,
                  color: Theme.of(context).primaryColor,
                  size: 24), // Smaller icon, theme-based color
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500)), // Smaller text, semi-bold
            ],
          ),
        ),
      ),
    );
  }
}

class RatingCard extends StatelessWidget {
  final double rating;
  final String review;
  final String userName;
  // Example addition: URL for user avatar image
  final String? userAvatarUrl;

  const RatingCard({
    super.key,
    required this.rating,
    required this.review,
    this.userName = "Anonymous",
    this.userAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Slightly wider card
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(
          horizontal: 0, vertical: 8), // Add some left and right margin
      decoration: BoxDecoration(
        color: Colors.white, // A clean white background
        borderRadius:
            BorderRadius.circular(20), // More pronounced rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2), // Minor adjustments for a subtle shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    userAvatarUrl != null ? NetworkImage(userAvatarUrl!) : null,
                backgroundColor: Colors.grey[200],
                radius: 20, // Lighter grey when no image
                child: userAvatarUrl == null
                    ? Icon(Icons.person_outline,
                        color: Colors.grey[600], size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  userName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RatingBarIndicator(
            rating: rating,
            itemBuilder: (context, index) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            itemCount: 5,
            itemSize: 24.0,
            direction: Axis.horizontal,
          ),
          const SizedBox(height: 8),
          Text(
            review.isEmpty ? "No review provided." : review,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
