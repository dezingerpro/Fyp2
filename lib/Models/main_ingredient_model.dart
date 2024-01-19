class MainIngredient {
  String id;
  String mname;

  MainIngredient({required this.id, required this.mname});

  factory MainIngredient.fromJson(Map<String, dynamic> json) {
    return MainIngredient(
      id: json['_id'],
      mname: json['mname'],
    );
  }
}