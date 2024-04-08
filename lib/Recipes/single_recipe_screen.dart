import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../API/api.dart';
import '../Models/ingredients_model.dart';
import '../Models/ratings_model.dart';
import '../Models/recipe_model.dart';
import '../Cart+Checkout/cart.dart';
import '../provider/cart_provider.dart'; // Adjust the import path as necessary

class RecipeIngredients extends StatefulWidget {
  final Recipe recipe;

  const RecipeIngredients({super.key, required this.recipe});

  @override
  _RecipeIngredientsState createState() => _RecipeIngredientsState();
}

class _RecipeIngredientsState extends State<RecipeIngredients> {
  late YoutubePlayerController _youtubePlayerController;
  final _reviewController = TextEditingController();
  late Future<List<Rating>> _ratingsFuture;
  List<Rating> _ratings = [];
  bool _isLoading = true;
  double _userRating = 0;

  @override
  void initState() {
    super.initState();
    _fetchRatings();
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
      List<Rating> ratingsList = await Api.fetchRatingsForRecipe(widget.recipe.id);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rating submitted successfully')));
      _reviewController.clear(); // Clear the review text field
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit rating')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(widget.recipe.rname),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => CartPage())),
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              widget.recipe.rimage,
              height: 250.0,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
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
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          InfoCard(icon: Icons.timer, label: '45 mins', tooltip: 'Prep Time'),
                          InfoCard(icon: Icons.star_rate, label: '4.5', tooltip: 'Rating'),
                          InfoCard(icon: Icons.thumb_up_alt_outlined, label: 'Like', isButton: true, onTap: () {
                            print('Like tapped'); // Implement your like functionality
                          }),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    const Text(
                      'Ingredients:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row for Column Names
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2, // Adjust flex to control width ratio between Qty and Ingredient Name
                                child: Text(
                                  'Qty',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 9, // Adjust accordingly
                                child: Text(
                                  'Ingredient Name',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              // Placeholder for icon alignment
                              SizedBox(width: 24), // Assuming your icons are about 24x24
                            ],
                          ),
                        ),
                        // Ingredients List
                        ListView.separated(
                          shrinkWrap: true, // Use it to make ListView take up minimal space
                          physics: NeverScrollableScrollPhysics(), // to disable scrolling within the ListView
                          itemCount: widget.recipe.ringredients.length,
                          itemBuilder: (context, index) {
                            final ingredient = widget.recipe.ringredients[index];
                            return Row(
                              children: [
                                // Quantity
                                Expanded(
                                  flex: 2, // Same flex ratio as in the header
                                  child: Text(
                                    '${ingredient['quantity']}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                // Ingredient Name
                                Expanded(
                                  flex: 8, // Same flex ratio as in the header
                                  child: Text(
                                    ingredient['ingredientName'],
                                    style: TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Add to Cart Icon
                                IconButton(
                                  icon: Icon(Icons.add_shopping_cart, color: Colors.deepPurple),
                                  onPressed: () async {
                                    Ingredient? detailedIngredient = await Api.fetchIngredientDetails(ingredient['ingredientName']);
                                    if (detailedIngredient != null) {
                                      _showQuantityDialog(context, detailedIngredient, cartProvider);
                                    } else {
                                      // Optionally, show an error message
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) => Divider(height: 1), // Adds a line between each item
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _ratings.isEmpty
                    ? Text("No reviews yet.")
                    : Container(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _ratings.length,
                    itemBuilder: (context, index) {
                      final rating = _ratings[index];
                      return RatingCard(
                        rating: rating.rating,
                        review: rating.review,
                        userName: rating.user.uname, // Placeholder for user name
                      );
                    },
                  ),
                ),
              ),

                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rate this Recipe:',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          RatingBar.builder(
                            initialRating: 0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
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
                            decoration: InputDecoration(
                              hintText: 'Leave a review (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: _submitRating,
                              child: Text('Submit Rating'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Recipe Video:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    YoutubePlayer(
                      controller: _youtubePlayerController,
                      showVideoProgressIndicator: true,
                      onReady: () {
                        print('Player is ready.');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showQuantityDialog(BuildContext context, Ingredient item, CartProvider cartProvider) {
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
              height: currentQuantity > 0 ? 250 : 200, // Adjust height based on current quantity
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Adjust Quantity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => setState(() => quantity = quantity > 0 ? quantity - 1 : 0),
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
  Future<List<Rating>>getRatings() async {
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: isButton ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 100,
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: Colors.deepPurple, size: 28),
              SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 16)),
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
      width: 280, // Slightly wider card
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[100]!, Colors.grey[300]!], // Adjust colors based on your theme
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 6,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (userAvatarUrl != null)
                CircleAvatar(
                  backgroundImage: NetworkImage(userAvatarUrl!),
                  radius: 16,
                )
              else
                CircleAvatar(
                  backgroundColor: Colors.grey[400],
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                  radius: 16,
                ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  userName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          RatingBarIndicator(
            rating: rating,
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: Colors.deepOrange,
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


