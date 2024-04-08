class Ingredient {
  final String id;
  final String name;
  final String image;
  final num stock;
  final num price;
  final String quantityType; // New field for quantity type

  Ingredient({
    required this.id,
    required this.name,
    required this.image,
    required this.stock,
    required this.price,
    required this.quantityType, // Initialize in constructor
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['_id'] ?? '',
      name: json['iname'] ?? '',
      image: json['iimage'] ?? '',
      stock: json['istock'] ?? 0,
      price: json['iprice'] ?? 0.0,
      quantityType: json['quantityType'] ?? 'Pieces', // Default value or from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'iname': name,
      'iimage': image,
      'istock': stock,
      'iprice': price,
      'quantityType': quantityType, // Include in JSON
    };
  }
}
