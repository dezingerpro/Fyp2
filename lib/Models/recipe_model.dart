class Recipe {
  final String id;
  final String rname;
  final List<Map<String, dynamic>> ringredients;
  final num rratings;
  final String rimage;
  final String rlink;
  final String rmainingredient;
  final String rtype;
  final List<String> allergens;  // Added allergens field
  final List<String> rinstructions;  // Added allergens field
  double similarity;


  Recipe({
    required this.id,
    required this.rname,
    required this.ringredients,
    required this.rratings,
    required this.rimage,
    required this.rlink,
    required this.rmainingredient,
    required this.rtype,
    required this.allergens, // Initialize allergens in the constructor
    required this.rinstructions, // Initialize allergens in the constructor
    this.similarity = 0.0, // Add a default value for similarity
  });

  // Add a method to update the similarity score if needed
  void updateSimilarity(double score) {
    similarity = score;
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['_id'],
      rname: json['rname'],
      ringredients: parseIngredients(json['ringredients']),
      rratings: json['rratings'],
      rimage: json['rimage'],
      rlink: json['rlink'],
      rmainingredient: json['rmainingredient'],
      rtype: json['rtype'],
      rinstructions: List<String>.from(json['rinstructions'] ?? []),
      similarity: json['similarity']?.toDouble() ?? 0.0, // Safe conversion to double
      allergens: List<String>.from(json['allergens'] ?? []), // Initialize allergens field from JSON, defaulting to an empty list if null
    );
  }

  static List<Map<String, dynamic>> parseIngredients(dynamic jsonIngredients) {
    List<Map<String, dynamic>> ingredientsList = [];
    if (jsonIngredients is List) {
      for (var ingredient in jsonIngredients) {
        if (ingredient is Map<String, dynamic>) {
          final Map<String, dynamic> parsedIngredient = {
            'ingredientName': ingredient['ingredientName'] ?? 'Unknown',
            'quantity': ingredient['quantity'] ?? '0',
            'qtytype': ingredient['qtytype'] ?? 'units',
            'extra': ingredient['extra'] ?? '',
            'secondaryName': ingredient['secondaryName'] ?? '',
          };
          ingredientsList.add(parsedIngredient);
        }
      }
    }
    return ingredientsList;
  }
}
