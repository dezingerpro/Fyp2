import 'package:flutter/material.dart';
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

  const RecipeIngredients({super.key, required this.recipe});

  @override
  _RecipeIngredientsState createState() => _RecipeIngredientsState();
}

class _RecipeIngredientsState extends State<RecipeIngredients>
    with SingleTickerProviderStateMixin {
  late YoutubePlayerController _youtubePlayerController;
  final _reviewController = TextEditingController();
  late Future<List<Rating>> _ratingsFuture;
  List<Rating> _ratings = [];
  bool _isLoading = true;
  double _userRating = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _fetchRatings();
    _tabController = TabController(length: 3, vsync: this);
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId('bFpfqGT5u-k')!,
      flags: YoutubePlayerFlags(
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
    String _userId = prefs.getString('userId') as String;
    // Submit the rating and review to your API
    final success = await Api.submitRecipeRating(
      userId: _userId,
      recipeId: widget.recipe.id,
      rating: _userRating,
      review: _reviewController.text,
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rating submitted successfully')));
      _reviewController.clear(); // Clear the review text field
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to submit rating')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.purple,
      //   title: Text(widget.recipe.rname),
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      // ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 250.0,
              leading: SizedBox.shrink(),
              floating: false,
              pinned: false,
              backgroundColor: Colors.transparent, // Make AppBar background transparent
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  var top = constraints.biggest.height;
                  return Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.all(8.0), // Padding around the image
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20), // Rounded corners
                                image: DecorationImage(
                                  image: NetworkImage(widget.recipe.rimage),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: top > 70 ? 30 : 10, // Adjust this value to position the button correctly (dynamic based on AppBar height)
                          left: 20,
                          child: CircleAvatar( // Circle background for the icon
                            backgroundColor: Colors.white, // White circle
                            radius: 20, // Size of the circle
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.black), // Black arrow icon
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.recipe.rname,  // Assuming the recipe name is stored here
                    style: TextStyle(
                      fontSize: 24,  // Large text size for prominence
                      fontWeight: FontWeight.bold,  // Bold for emphasis
                      color: Colors.deepPurple,  // Modern color choice that matches the icon color
                    ),
                  ),
                ),
                SizedBox(height: 20),  // Spacing between the InfoCard and the title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    InfoCard(
                        icon: Icons.timer,
                        label: '45 mins',
                        tooltip: 'Prep Time'),
                    InfoCard(
                        icon: Icons.star_rate, label: '4.5', tooltip: 'Rating'),
                    InfoCard(
                        icon: Icons.thumb_up_alt_outlined,
                        label: 'Like',
                        isButton: true,
                        onTap: () {
                          print(
                              'Like tapped'); // Implement your like functionality
                        }),
                  ],
                ),
                SizedBox(height: 10),  // Spacing between the InfoCard and the title
                DefaultTabController(
                  length: 3,
                  child: Expanded(
                    child: Column(
                      children: [
                        TabBar(
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
        padding: const EdgeInsets.only(top: 8.0, right: 8.0, bottom: 8.0), // Reduced left padding
        child: ListView.builder(  // Changed from ListView.separated to ListView.builder
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.recipe.ringredients.length,
          itemBuilder: (context, index) {
            final ingredient = widget.recipe.ringredients[index];
            bool hasImage = ingredient['image'] != null && ingredient['image'].isNotEmpty;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.add_shopping_cart, color: Colors.deepPurple),
                  onPressed: () async {
                    Ingredient? detailedIngredient = await Api.fetchIngredientDetails(ingredient['ingredientName']);
                    if (detailedIngredient != null) {
                      _showQuantityDialog(context, detailedIngredient, cartProvider);
                    } else {
                      print('Error fetching ingredient details'); // Optionally, handle this visibly
                    }
                  },
                ),
                hasImage ? ClipRRect(
                  borderRadius: BorderRadius.circular(8), // Rounded corners for the image
                  child: Image.network(
                    ingredient['image'],
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ) : CircleAvatar(
                  backgroundColor: Colors.grey[300], // Light grey background for the info icon
                  child: Icon(Icons.info_outline, color: Colors.black),
                  radius: 20,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      ingredient['ingredientName'],
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Text(
                  ingredient['quantity'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
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
            Text("Description:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            //Text(widget.recipe.description ?? "No description available.", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
           // Text("Cooking Time: ${widget.recipe.cookingTime} minutes", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            //Text("Servings: ${widget.recipe.servings}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text('Rate and Review:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 8.0),  // Increased spacing for a cleaner look
              itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _userRating = rating;
                });
              },
            ),

            SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Leave a review (Optional)',
                hintStyle: TextStyle(color: Colors.grey[500]),  // Lighter hint text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),  // Rounded corners for the field
                  borderSide: BorderSide.none,  // No border
                ),
                filled: true,
                fillColor: Colors.grey[200],  // Light grey fill for subtlety
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _submitRating,
                child: Text('Submit Rating'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple,  // Background color
                  onPrimary: Colors.white,  // Text color
                  elevation: 2,  // Subtle shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),  // Rounded edges
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),  // Padding for a better shape
                ),
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
          ? Center(child: CircularProgressIndicator())
          : _ratings.isEmpty
              ? Text("No reviews yet.")
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
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
              padding: EdgeInsets.all(16),
              height: currentQuantity > 0
                  ? 250
                  : 200, // Adjust height based on current quantity
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Adjust Quantity",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => setState(
                            () => quantity = quantity > 0 ? quantity - 1 : 0),
                      ),
                      Text(quantity.toString(), style: TextStyle(fontSize: 18)),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => setState(() => quantity++),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    child: Text('Confirm'),
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
    print("GETSETGO");
    print("HIH$listoflol");
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
    Key? key,
    required this.icon,
    required this.label,
    this.tooltip = '',
    this.isButton = false,
    this.onTap,
  }) : super(key: key);

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
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: Theme.of(context).primaryColor, size: 24), // Smaller icon, theme-based color
              SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)), // Smaller text, semi-bold
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
    Key? key,
    required this.rating,
    required this.review,
    this.userName = "Anonymous",
    this.userAvatarUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Slightly wider card
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8), // Add some left and right margin
      decoration: BoxDecoration(
        color: Colors.white, // A clean white background
        borderRadius: BorderRadius.circular(20), // More pronounced rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2), // Minor adjustments for a subtle shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: userAvatarUrl != null ? NetworkImage(userAvatarUrl!) : null,
                backgroundColor: Colors.grey[200], // Lighter grey when no image
                child: userAvatarUrl == null ? Icon(Icons.person_outline, color: Colors.grey[600], size: 20) : null,
                radius: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  userName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          RatingBarIndicator(
            rating: rating,
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            itemCount: 5,
            itemSize: 24.0,
            direction: Axis.horizontal,
          ),
          SizedBox(height: 8),
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
