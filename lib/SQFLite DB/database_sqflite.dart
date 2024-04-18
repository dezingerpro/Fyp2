import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  initDB() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'recipes.db');
    return await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      // Create the recipes table
      await db.execute('''
        CREATE TABLE Recipes (
          id TEXT PRIMARY KEY,
          rname TEXT,
          rmainingredient TEXT,
          rratings REAL,
          rimage TEXT,
          rlink TEXT,
          rtype TEXT
        );
      ''');

      // Create the ingredients table
      await db.execute('''
        CREATE TABLE Ingredients (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          recipeId TEXT,
          ingredientName TEXT,
          quantity TEXT,
          FOREIGN KEY (recipeId) REFERENCES Recipes(id)
        );
      ''');

      // Create the allergens table
      await db.execute('''
        CREATE TABLE Allergens (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          recipeId TEXT,
          allergen TEXT,
          FOREIGN KEY (recipeId) REFERENCES Recipes(id)
        );
      ''');
    });
  }

  Future<bool> insertRecipe(Map<String, dynamic> recipe, List<Map<String, dynamic>> ingredients, List<String> allergens) async {
    final db = await database;
    try {
      await db.transaction((txn) async {
        await txn.insert('Recipes', recipe, conflictAlgorithm: ConflictAlgorithm.replace);
        for (var ingredient in ingredients) {
          await txn.insert('Ingredients', {
            'recipeId': recipe['id'],
            'ingredientName': ingredient['ingredientName'],
            'quantity': ingredient['quantity'],
          });
        }
        for (var allergen in allergens) {
          await txn.insert('Allergens', {
            'recipeId': recipe['id'],
            'allergen': allergen,
          });
        }
      });
      return true; // Return true if all inserts are successful
    } catch (e) {
      print("Failed to insert recipe into database: $e");
      return false; // Return false if an error occurs
    }
  }


  Future<List<Map<String, dynamic>>> getRecipes() async {
    final db = await database;
    print("HELLO");
    List<Map<String, dynamic>> recipes = await db.query('Recipes');
    print("HELLO44");
    for (var recipe in recipes) {
      // Clone the map to ensure it's mutable
      var mutableRecipe = Map<String, dynamic>.from(recipe);

      // Perform operations on mutableRecipe instead of the original recipe
      try {
        final ingredients = await db.query('Ingredients', where: 'recipeId = ?', whereArgs: [mutableRecipe['id']]);
        final allergens = await db.query('Allergens', where: 'recipeId = ?', whereArgs: [mutableRecipe['id']]);
        mutableRecipe['ringredients'] = ingredients;
        mutableRecipe['allergens'] = allergens.map((a) => a['allergen']).toList();
      } catch (e) {
        print("Failed processing recipe ID: ${mutableRecipe['id']} with error: $e");
      }
    }

    print("All recipes processed.");
    return recipes;
  }

}
