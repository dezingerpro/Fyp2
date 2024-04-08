class Allergen {
  final String allergen;
  final List<String> ingredients;

  Allergen({required this.allergen, required this.ingredients});

  factory Allergen.fromJson(Map<String, dynamic> json) {
    return Allergen(
      allergen: json['allergen'],
      ingredients: List<String>.from(json['ingredients']),
    );
  }
}