class Rating {
  final String id;
  final String recipeId;
  final UserR user; // This will use the User model
  final double rating;
  final String review;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.recipeId,
    required this.user,
    required this.rating,
    required this.review,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['_id'],
      recipeId: json['recipeId'],
      user: UserR.fromJson(json['userId']), // Parse the nested User object
      rating: json['rating'].toDouble(),
      review: json['review'] ?? "", // Provide a default empty string if null
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class UserR {
  final String id;
  final String uname;

  UserR({required this.id, required this.uname});

  factory UserR.fromJson(Map<String, dynamic> json) {
    return UserR(
      id: json['_id'],
      uname: json['uname'],
    );
  }
}
