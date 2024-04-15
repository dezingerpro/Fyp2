import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:fyp2/Models/recipe_model.dart';
import 'package:fyp2/Models/security_question.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/allergy_model.dart';
import '../Models/ingredients_model.dart';
import '../Models/main_ingredient_model.dart';
import '../Models/order_model.dart';
import '../Models/ratings_model.dart';
import '../Models/user_model.dart';
import '../provider/cart_provider.dart';

class Api {


  static bool? adminStatus;
  static late String baseUrl;

  static Future<void> initIp(String ip) async {
    baseUrl = "http://$ip:2000/api/";
    _submitIPpython(ip);
  }

  static void _submitIPpython(String ip) async {
    String url = '${baseUrl}submit-ip';  // Change 'your-server-ip' to your actual server IP
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ip': ip}),
      );
      print('Server responded: ${response.body}');
    } catch (e) {
      print('Error sending IP: $e');
    }
  }

  //USER REGISTRATION
  static Future<int> addUser(User user) async {
    Map<String, dynamic> userData = user.toJson();
    userData['isAdmin'] = userData['isAdmin'].toString();
    //print(userData);
    var url = Uri.parse("${baseUrl}add_user");
    try {
      final res = await http.post(url, body: userData);
      //print(res);
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
        return 200;
      } else if (res.statusCode == 205) {
        return 205;
      } else {
        return 400;
      }
    } catch (e) {
      debugPrint(e.toString());
      return 400;
    }
  }

  // Method to fetch user by ID
  static Future<dynamic> fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      return null; // Early return if no user ID is found
    }

    try {
      final response = await http.get(Uri.parse('${baseUrl}user/$userId'));
      if (response.statusCode == 200) {
        return json.decode(response.body); // Return user data
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //UPDATE USER
  static Future<bool> updateUserDetails(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      return false;
    }

    final response = await http.patch(
      Uri.parse('${Api.baseUrl}user/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  //USER LOGIN
  static Future<bool> getUser(Map userData,BuildContext context) async {
    var url = Uri.parse("${baseUrl}get_user");
    //print(email+password);
    final res = await http.post(url, body: userData);
    try {
      if (res.statusCode == 401) {
        var receivedData = jsonDecode(res.body);
        var data = receivedData['user'];
        var ingredientsData = receivedData['ingredients'];
        final prefs = await SharedPreferences.getInstance();
        if (data['isAdmin'] == true) {
          prefs.setBool('isAdmin', true);
          adminStatus = true;
        }
        else {
          prefs.setBool('isAdmin', false);
          adminStatus = false;
        }
        String userId = data['_id']; // Make sure to replace 'userId' with the actual key used in your API response
        prefs.setString('userId', userId);
        updateCartFromData(data['ucart'],ingredientsData,context);
        return true;
      } else if (res.statusCode == 402) {
      } else if (res.statusCode == 403) {
      }
    } catch (e) {
    }
    return false;
  }

  static void updateCartFromData(List<dynamic> ucart, List<dynamic> ingredientsData,BuildContext context) {
    final ingredientMap = {for (var ingredient in ingredientsData) ingredient['_id']: Ingredient.fromJson(ingredient)};

    // Use .map() and .where() to filter out any potential nulls
    final List<CartItem> updatedCartItems = ucart.map((cartItem) {
      final ingredientId = cartItem['id'];
      final ingredient = ingredientMap[ingredientId];
      if (ingredient != null) {
        return CartItem(
          item: ingredient,
          quantity: cartItem['quantity'],
        );
      }
      // Returning null here; make sure to filter these out
      return null;
    }).where((cartItem) => cartItem != null) // Remove nulls
        .cast<CartItem>() // This cast is now safe; all nulls are filtered out
        .toList();

    // Now updatedCartItems is correctly typed as List<CartItem>
    // Update cart items in your cart provider
    final cartProvider = Provider.of<CartProvider>(context,listen: false);
    cartProvider.setCartItems(updatedCartItems); // Implement setCartItems in CartProvider
  }




//GET SECURITY QUESTION
  static Future<List<securityQuestion>> fetchQuestions() async {
    var url = Uri.parse("${baseUrl}get_question");

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as List<dynamic>;

        List<securityQuestion> questions = data.map((item) {
          return securityQuestion.fromJson(item);
        }).toList();

        return questions;
      } else {
        throw Exception(
            'Failed to load ingredients. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to connect to the server');
    }
  }

//FORGOT PASSWORD

  static Future<String> forgotPassword(Map userData) async {
    var url = Uri.parse("${baseUrl}forgot_password");
    final res = await http.post(url, body: userData);
    //print(res.statusCode);
    try {
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(res.body);
        //print(data['usecurityQuestion']);
        return data['usecurityQuestion'] as String;
        //return true;
      } else if (res.statusCode == 205) {
        return "invalid";
      }
    } catch (e) {
    }
    return "error";
  }

  //check security question answer
  static Future<bool> checkAnswer(String email, String answer) async {
    var url = Uri.parse("${baseUrl}check_answer");
    var data = {"uemail": email, "uanswer": answer};
    try {
      final response = await http.post(url, body: data);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
    }
    return false;
  }

  //UPDATE PASSWORD
  static updatePassword(Map data) async {
    var url = Uri.parse("${baseUrl}update_password");
    try {
      final res = await http.patch(url, body: data);

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
      } else {
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

// RECIPE FETCH
  static Future<List> getRecipeAll() async {
    var url = Uri.parse("${baseUrl}get_allrecipe");
    final res = await http.post(url);
    try {
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body) as List<dynamic>;
        return data;
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  static Future<bool> updateLastViewedRecipes(String newRecipeName) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId == null) {
      // Handle scenario where there's no user ID (e.g., guest users)
      return false;
    }

    List<String> currentLastViewed = await fetchLastViewedRecipes(userId);

    // Remove the recipe if it already exists to avoid duplicates
    //currentLastViewed.remove(newRecipeName);
    // Then insert it at the beginning
    currentLastViewed.insert(0, newRecipeName);

    // Ensure only the last five recipes are kept
    List<String> updatedLastViewed = currentLastViewed.length > 5
        ? currentLastViewed.sublist(0, 5)
        : currentLastViewed;

    // Send the update to the backend
    var response = await http.post(
      Uri.parse('${baseUrl}updateLastViewed'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'userId': userId,
        'lastViewedRecipes': updatedLastViewed,
      }),
    );

    return response.statusCode == 200;
  }

// You need to implement this method to fetch the current last viewed recipes
  static Future<List<String>> fetchLastViewedRecipes(String userId) async {
    var url = Uri.parse('${baseUrl}getLastViewedRecipes');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      List<dynamic> lastViewedRecipes = jsonDecode(
          response.body)['lastViewedRecipes'];
      return lastViewedRecipes.cast<String>();
    } else {
      // Handle error or return an empty list
      return [];
    }
  }

  //SEND INGREDIENTS
  static Future<List<String>> sendIngredients(
      List<String> selectedIngredients) async {
    var url = Uri.parse('${baseUrl}search_recipes');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ingredients": selectedIngredients}));
    List<String> recipeNames = [];
    if (response.statusCode == 200) {
      var recommendations = jsonDecode(response.body) as Map<String, dynamic>;
      // Extracting recipe names into a list
      var recommendedRecipes = recommendations['recommended_recipes'] as List;
      recipeNames = recommendedRecipes
          .map((recipe) => recipe['name'] as String)
          .toList();
      // Printing the list of recipe names
      return recipeNames;
    } else {
      // Handle errors
    }
    return recipeNames; // Return the list of recipe names
  }

  //FETCH RECOMMENDED RECIPE NAMES
  static Future<List<String>> fetchRecommendedRecipeNames() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId == null) {
      // Handle scenario where there's no user ID (e.g., guest users)
      return [];
    }
    // Your backend endpoint URL
    String apiUrl = '${baseUrl}recommended_recipes';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId, // Include userId in the request body
        }),
      );

      if (response.statusCode == 200) {
        // Parse the JSON response to extract recipe names
        final List<dynamic> recipeNamesJson = jsonDecode(response.body);
        final List<String> recipeNames = recipeNamesJson.map((name) =>
            name.toString()).toList();
        return recipeNames;
      } else {
        // Handle server errors or invalid status codes
        return [];
      }
    } catch (e) {
      // Handle network errors or JSON parsing errors
      return [];
    }
  }

  //ADD RATINGS
  static Future<bool> submitRecipeRating({
    required String recipeId,
    required String userId,
    required double rating,
    String? review,
  }) async {
    final url = Uri.parse('${baseUrl}add_ratings');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'recipeId': recipeId,
        'userId': userId,
        'rating': rating,
        'review': review,
      }),
    );
    if (response.statusCode == 201) {
      // Assuming a 201 status code means the rating was successfully created
      return true;
    } else {
      // Handle different statuses/errors appropriately in production code
      return false;
    }
  }

  //FETCH RATINGS
  static Future<List<Rating>> fetchRatingsForRecipe(String recipeId) async {
    final url = Uri.parse('${baseUrl}get_ratings?recipeId=$recipeId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> ratingsJson = json.decode(response.body);
      return ratingsJson.map((json) => Rating.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load ratings');
    }
  }



  //GET MAIN INGREDIENT LIST
  static Future<List<MainIngredient>> fetchMainIngredients() async {
    var url = Uri.parse("${baseUrl}get_maining");

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as List<dynamic>;

        List<MainIngredient> ingredients = data.map((item) {
          return MainIngredient.fromJson(item);
        }).toList();

        return ingredients;
      } else {
        throw Exception('Failed to load ingredients. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to connect to the server');
    }
  }

  static Future<Ingredient?> fetchIngredientDetails(String ingredientName) async {
    var url = Uri.parse("${baseUrl}get_ingredient_details");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'ingredientName': ingredientName}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // Assuming the API returns the details for a single ingredient
        return Ingredient.fromJson(data);
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }


  //fetch ingredients
  static Future<List<Ingredient>> fetchIngredients() async {
    var url = Uri.parse("${baseUrl}get_ingredients");

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as List<dynamic>;

        List<Ingredient> ingredients = data.map((item) {
          return Ingredient.fromJson(item);
        }).toList();


        return ingredients;
      } else {
        throw Exception('Failed to load ingredients. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<List<Recipe>> getRecipe() async {
    var url = Uri.parse("${baseUrl}get_allrecipe");
    try {
      final res = await http.post(url);

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body) as List<dynamic>;
        List<Recipe> recipes = data.map((recipeJson) {
          return Recipe.fromJson(recipeJson);
        }).toList();
        return recipes;

      } else {
        // Handle non-200 status codes
        return [];
      }
    } catch (e) {
      // Handle exceptions
      return [];
    }
  }

  //place orders
  static Future<bool> placeOrder(String userId, List<Map<String, dynamic>> items, {String? voucher, String? name, String? phoneNumber, String? address}) async {
    final url = Uri.parse('${baseUrl}orders');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'userId': userId,
        'items': items,
      }),
    );

    return response.statusCode == 201; // Or another appropriate success code your API uses
  }

  //fetch orders
  static Future<List<Order>> fetchOrders() async {
    final url = Uri.parse('${baseUrl}get_orders'); // Adjust endpoint as needed
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> ordersJson = json.decode(response.body);
      return ordersJson.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  //update orders
  static Future<bool> updateOrderStatus(String orderId, String status) async {
    final response = await http.put(
      Uri.parse('${baseUrl}update_orders/$orderId/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );
    return response.statusCode == 200;
  }

  //search by user id orders
  static Future<List<Order>> fetchUserOrders(String userId) async {
    final response = await http.get(Uri.parse('${baseUrl}userOrders/$userId'));
    if (response.statusCode == 200) {
      List<dynamic> ordersJson = json.decode(response.body);
      return ordersJson.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders: ${response.statusCode}');
    }
  }

  //add recipe
  static addRecipe(Map productData) async {
    //print(productData);
    var url = Uri.parse("${baseUrl}add_recipe");
    try {
      final res = await http.post(url, body: productData);

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
      } else {
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //Update Recipe
  static updateRecipe(Map data) async {
    var url = Uri.parse("${baseUrl}update_recipe");
    try {
      final res = await http.put(url, body: data);

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
      } else {
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //DELETE RECIPE
  static deleteRecipe(id) async{
    var url = Uri.parse("${baseUrl}delete_recipe/$id");

    final res = await http.post(url);
    if(res.statusCode == 200){
    }else{
    }
  }

  //ADD INGREDIENT
  static Future<bool> addIngredient(Ingredient ingredient) async {
    final response = await http.post(
      Uri.parse('${baseUrl}add_ingredient'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(ingredient.toJson()),
    );
    return response.statusCode == 201;
  }

  //Update INGREDIENT
  static Future<bool> updateIngredient(String id, Ingredient ingredient) async {
    final response = await http.patch(
      Uri.parse('${baseUrl}update_ingredient/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(ingredient.toJson()),
    );
    return response.statusCode == 200;
  }

  //Delete INGREDIENT
  static Future<bool> deleteIngredient(String id) async {
    final response = await http.delete(Uri.parse('${baseUrl}delete_ingredient/$id'));
    return response.statusCode == 200;
  }

  //GET ALLERGY
  static Future<List<Allergen>> fetchAllergens() async {
    final response = await http.get(Uri.parse('${baseUrl}get_allergens'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Allergen.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load allergens');
    }
  }

  static Future<void> saveCartToDatabase(Map<String, CartItem> items,String userId) async {
    final url = Uri.parse('${baseUrl}updateCart');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'userId': userId,
          'ucart': items.entries.map((item) => {
            'ingredientName': item.value.item.name,
            'quantity': item.value.quantity,
            'id': item.value.item.id,
          }).toList(),
        }),
      );
      var hello = items.entries.map((item) => {
    'ingredientName': item.value.item.name,
    'quantity': item.value.quantity,
    'id': item.value.item.id,
    }).toList();


      if (response.statusCode == 200) {
      } else {
      }
    } catch (error) {
    }
  }

  static Future<void> reanalyzeRecipes() async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}analyze-recipes'),
      );
      if (response.statusCode == 200) {
      } else {
      }
    } catch (e) {
    }
  }

  // Future<void> fetchCart(String userId) async {
  //   final response = await http.get(Uri.parse('YOUR_BACKEND_URL/api/getCart/$userId'));
  //
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     if (data['success']) {
  //       // Update your cart provider with fetched cart contents
  //       // Assuming you have a method in your CartProvider for this
  //       CartProvider.updateCartFromDatabase(data['cartContents']);
  //     }
  //   } else {
  //     print("Failed to fetch cart");
  //   }
  // }


}
