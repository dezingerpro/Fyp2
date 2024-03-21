class Ingredient {
  final String id;
  final String name;
  final String image;
  final num stock; // Uncomment if needed
  final num price;

  Ingredient({
    required this.id,
    required this.name,
    required this.image,
  required this.stock,
    required this.price,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['_id'] ?? '', // Safe null-check before calling toString()
      name: json['iname'] ?? '', // Adding null safety
      image: json['iimage'] ?? '', // Adding null safety
      // For numerical fields, ensure there's a null check or a default value provided.
      stock: json['istock'] ?? 0,
      price: json['iprice'] ?? 0.0,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'iname': name,
      'iimage': image,
      'istock': stock.toString(),
      'iprice': price.toString(),
    };
  }
}
