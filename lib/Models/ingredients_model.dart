class Ingredient {
  final String id;
  final String name;
  final String image;
  //final num stock; // Uncomment if needed
  final num price;

  Ingredient({
    required this.id,
    required this.name,
    required this.image,
    //required this.stock,
    required this.price,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['_id'].toString(), // Convert id to string here
      name: json['iname'],
      image: json['iimage'],
      //stock: (json['istock'] is int) ? json['istock'] : num.parse(json['istock']),
      price: json['iprice'] is num ? json['iprice'] : num.parse(json['iprice'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'iname': name,
      'iimage': image,
      //'istock': stock.toString(),
      'iprice': price.toString(),
    };
  }
}
