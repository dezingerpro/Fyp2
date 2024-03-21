import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../API/api.dart';
import '../Models/ingredients_model.dart';
import '../Models/recipe_model.dart';
import '../cart.dart';
import '../provider/cart_provider.dart'; // Adjust the import path as necessary
// Import your Ingredient model if it's different from what's used in the Recipe model

class RecipeIngredients extends StatefulWidget {
  final Recipe recipe;

  const RecipeIngredients({super.key, required this.recipe});

  @override
  _RecipeIngredientsState createState() => _RecipeIngredientsState();
}

class _RecipeIngredientsState extends State<RecipeIngredients> {
  late YoutubePlayerController _youtubePlayerController;

  @override
  void initState() {
    super.initState();
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId('bFpfqGT5u-k')!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _youtubePlayerController.dispose();
    super.dispose();
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
                    Text(
                      widget.recipe.rname,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RatingBar.builder(
                      initialRating: widget.recipe.rratings.toDouble(),
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        // Handle rating update if necessary
                      },
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

}
