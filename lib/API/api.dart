import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:fyp2/Models/recipe_model.dart';
import 'package:fyp2/Models/security_question.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/ingredients_model.dart';
import '../Models/main_ingredient_model.dart';
import '../Models/order_model.dart';
import '../Models/user_model.dart';

class Api {
  static const baseUrl = "http://192.168.18.108:2000/api/";
  static bool ?adminStatus;

  //USER REGISTRATIO
  static Future<int> addUser(User user) async {
    Map<String, dynamic> userData = user.toJson();
    userData['isAdmin'] = userData['isAdmin'].toString();
    //print(userData);
    var url = Uri.parse("${baseUrl}add_user");
    try {
      final res = await http.post(url, body: userData);
      print("Posted successfully");
      print(res.statusCode);
      //print(res);
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
        print(data);
        return 200;
      } else  if (res.statusCode == 205){
        print("Email Already Taken");
        return 205;
      }else{
        print("Failed to get response");
        return 400;
      }
    } catch (e) {
      print("HI");
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
        print('Failed to load user with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error occurred while fetching user: $e');
      return null;
    }
  }

  //UPDATE USER
  static Future<bool> updateUserDetails(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print("User ID not found");
      return false;
    }

    final response = await http.put(
      Uri.parse('${Api.baseUrl}user/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      print("User updated successfully");
      return true;
    } else {
      print("Failed to update user. Status code: ${response.statusCode}");
      return false;
    }
  }

  //USER LOGIN
  static Future<bool> getUser(Map userData) async {
  var url = Uri.parse("${baseUrl}get_user");
  //print(email+password);
  final res = await http.post(url,body: userData);

    try{
      if(res.statusCode == 401){
         var data = jsonDecode(res.body);
         final prefs = await SharedPreferences.getInstance();
         if(data['isAdmin']==true){
           prefs.setBool('isAdmin', true);
           adminStatus = true;
         }
         else{
           prefs.setBool('isAdmin', false);
           adminStatus = false;
         }
         String userId = data['_id']; // Make sure to replace 'userId' with the actual key used in your API response
         prefs.setString('userId', userId);
         return true;
      }else if(res.statusCode == 402){
        print("PLEASE CHECK YOUR PASSWORD");
      }else if(res.statusCode == 403){
        print("PLEASE CHECK YOUR Email");
      }
    }catch(e){
      print(e.toString());
    }
    return false;
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
        throw Exception('Failed to load ingredients. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to connect to the server');
    }
  }

//FORGOT PASSWORD

  static Future<String> forgotPassword(Map userData) async {
    var url = Uri.parse("${baseUrl}forgot_password");
    final res = await http.post(url,body: userData);
    //print(res.statusCode);
    try{
      if(res.statusCode == 200){
        final Map<String, dynamic> data = json.decode(res.body);
        //print(data['usecurityQuestion']);
        return data['usecurityQuestion'] as String;
        //return true;
      }else if(res.statusCode == 205){
        return "invalid";
      }
    }catch(e){
      print(e.toString());
    }
    return "error";
  }

  //check security question answer
  static Future<bool> checkAnswer(String email, String answer) async {
    var url = Uri.parse("${baseUrl}check_answer");
    print(answer);
    var data = {"uemail": email, "uanswer": answer};
    try {
      final response = await http.post(url, body: data);
      if (response.statusCode == 200) {
        print("200");
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error during API call: $e");
    }
    return false;
  }

  //UPDATE PASSWORD
  static updatePassword(Map data) async {
    var url = Uri.parse("${baseUrl}update_password");
    try {
      final res = await http.patch(url, body: data);
      print("Posted successfully");

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
        print(data);
      } else {
        print("Failed to get response");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

// RECIPE FETCH
  static Future<List> getRecipeAll() async {
    var url = Uri.parse("${baseUrl}get_allrecipe");
    final res = await http.post(url);
    try{
      if(res.statusCode == 200){
        var data = jsonDecode(res.body) as List<dynamic>;
        return data;
      }
    }catch(e){
      print(e.toString());
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
      List<dynamic> lastViewedRecipes = jsonDecode(response.body)['lastViewedRecipes'];
      print(lastViewedRecipes);
      return lastViewedRecipes.cast<String>();
    } else {
      // Handle error or return an empty list
      print('Failed to fetch last viewed recipes. Status code: ${response.statusCode}.');
      return [];
    }
  }

  //SEND INGREDIENTS
  static Future<List<String>> sendIngredients(List<String> selectedIngredients) async {
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
      print('Request failed with status: ${response.statusCode}.');
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
    final String apiUrl = '${baseUrl}recommended_recipes';
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
        final List<String> recipeNames = recipeNamesJson.map((name) => name.toString()).toList();
        print(recipeNamesJson);
        print(recipeNames);
        return recipeNames;
      } else {
        // Handle server errors or invalid status codes
        print('Failed to fetch recommended recipe names. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // Handle network errors or JSON parsing errors
      print('An error occurred while fetching recommended recipe names: $e');
      return [];
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
        print(data);

        // Assuming the API returns the details for a single ingredient
        return Ingredient.fromJson(data);
      } else {
        print('Failed to load ingredient details. Status Code: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Exception when fetching ingredient details: $error');
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
        print(data);

        List<Ingredient> ingredients = data.map((item) {
          print(item);
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
        print('Request failed with status: ${res.statusCode}');
        return [];
      }
    } catch (e) {
      // Handle exceptions
      print('Exception occurred: $e');
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
      print(productData);
      final res = await http.post(url, body: productData);
      print("Posted successfully");

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
        print(data);
      } else {
        print("Failed to get response");
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
      print("Posted successfully");

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
        print(data);
      } else {
        print("Failed to get response");
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
      print(jsonDecode(res.body));
    }else{
      print('Fail to delete');
    }
  }
}
