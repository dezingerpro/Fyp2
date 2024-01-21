import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../Models/recipe_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RecipeIngredients extends StatelessWidget {
  final Recipe recipe;
  final List<Map<String, dynamic>> selectedIngredients = [];

  RecipeIngredients({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(recipe.rname),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height + 280,
          child: Stack(
            children: [
              ClipRRect(
                child: Image.network(
                  recipe.rimage,
                  height: 250.0,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
              Positioned(
                top: 223,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                  //color: Colors.purple,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                '${recipe.rname}',
                                style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                  top: 10.0, right: 25, bottom: 10),
                              child: Icon(
                                Icons.favorite_border_rounded,
                              ),
                            )
                          ],
                        ),
                        RatingBar.builder(
                          initialRating: recipe.rratings.toDouble(),
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemSize: 30,
                          itemCount: 5,
                          ignoreGestures: true,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (double value) {},
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          children: [
                            Icon(
                              Icons.restaurant,
                              size: 24.0,
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              'Main Ingredient: ',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16.0),
                            leading: StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return Checkbox(
                                  value: false,
                                  onChanged: (value) {
                                    setState(() {
                                      // Handle checkbox state
                                    });
                                  },
                                );
                              },
                            ),
                            title: Text(
                              '${recipe.rmainingredient}',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        const Text(
                          'Ingredients:',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: recipe.ringredients.map((ingredient) {
                            return Card(
                              elevation: 5,
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16.0),
                                leading: StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return Checkbox(
                                      value: selectedIngredients
                                          .contains(ingredient),
                                      onChanged: (value) {
                                        setState(() {
                                          if (selectedIngredients
                                              .contains(ingredient)) {
                                            selectedIngredients
                                                .remove(ingredient);
                                          } else {
                                            selectedIngredients.add(ingredient);
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                                title: Text(
                                  '${ingredient['quantity']} ${ingredient['ingredientName']}',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'YouTube Video',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.purple,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        YoutubePlayer(
                          controller: YoutubePlayerController(
                            initialVideoId: 'u66pG73UroY',
                            flags: YoutubePlayerFlags(
                              autoPlay: false,
                              mute: false,
                            ),
                          ),
                          showVideoProgressIndicator: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
