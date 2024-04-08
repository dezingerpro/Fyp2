class User {
  String? id = '';
  String username;
  String email;
  String password;
  String mobileNumber;
  String city;
  String streetAddress;
  String houseDetails;
  String usecurityQuestion;
  String uanswer;
  bool isAdmin;
  List<Map<String, dynamic>> ucart;
  List<String> allergies; // New field for allergies
  List<String> savedRecipes; // New field for saved recipes

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.mobileNumber,
    required this.city,
    required this.streetAddress,
    required this.houseDetails,
    required this.usecurityQuestion,
    required this.uanswer,
    required this.isAdmin,
    this.ucart = const [],
    this.allergies = const [], // Initialize the new field
    this.savedRecipes = const [], // Initialize the new field
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['uname'] as String? ?? "Unknown User",
      email: json['uemail'],
      password: json['upass'],
      mobileNumber: json['umobile'] ?? '',
      city: json['ucity'] ?? '',
      streetAddress: json['ustreet'] ?? '',
      houseDetails: json['uhouse'] ?? '',
      usecurityQuestion: json['usecurityQuestion'] ?? '',
      uanswer: json['uanswer'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      ucart: List<Map<String, dynamic>>.from(json['ucart'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []), // Parse allergies from JSON
      savedRecipes: List<String>.from(json['savedRecipes'] ?? []), // Parse saved recipes from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      //'id': id, // Uncomment if you decide to serialize the ID
      'uname': username,
      'uemail': email,
      'upass': password,
      'umobile': mobileNumber,
      'ucity': city,
      'ustreet': streetAddress,
      'uhouse': houseDetails,
      'usecurityQuestion': usecurityQuestion,
      'uanswer': uanswer,
      'isAdmin': isAdmin,
      'ucart': ucart,
      'allergies': allergies, // Serialize allergies field
      'savedRecipes': savedRecipes, // Serialize saved recipes field
    };
  }
}
