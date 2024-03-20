class Recipe {
  final String id; // Added _id field
  final String rname;
  final List<Map<String, dynamic>> ringredients;
  final num rratings;
  final String rimage;
  final String rlink;
  final String rmainingredient; // Added mainIngredient field
  final String rtype; // Added rtype field for recipe type

  Recipe({
    required this.id,
    required this.rname,
    required this.ringredients,
    required this.rratings,
    required this.rimage,
    required this.rlink,
    required this.rmainingredient,
    required this.rtype, // Initialize rtype in the constructor
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['_id'], // Initialize _id field from JSON
      rname: json['rname'],
      ringredients: parseIngredients(json['ringredients']),
      rratings: json['rratings'],
      rimage: json['rimage'],
      rlink: json['rlink'],
      rmainingredient: json['rmainingredient'], // Initialize mainIngredient field from JSON
      rtype: json['rtype'], // Initialize rtype field from JSON
    );
  }

  static List<Map<String, dynamic>> parseIngredients(dynamic jsonIngredients) {
    List<Map<String, dynamic>> ingredientsList = [];
    if (jsonIngredients is List) {
      jsonIngredients.forEach((ingredient) {
        if (ingredient is Map<String, dynamic>) {
          final Map<String, dynamic> parsedIngredient = {
            'ingredientName': ingredient['ingredientName'] ?? 'Unknown',
            'quantity': ingredient['quantity'] ?? '',
          };
          ingredientsList.add(parsedIngredient);
        }
      });
    }
    return ingredientsList;
  }
}
