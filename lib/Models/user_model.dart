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
  List<String> allergies;
  List<String> savedRecipes;

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
    this.allergies = const [],
    this.savedRecipes = const [],
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
      ucart: (json['ucart'] as List<dynamic>).map((e) => Map<String, dynamic>.from(e)).toList(),
      allergies: List<String>.from(json['allergies'] ?? []),
      savedRecipes: List<String>.from(json['savedRecipes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'allergies': allergies,
      'savedRecipes': savedRecipes,
    };
  }
}