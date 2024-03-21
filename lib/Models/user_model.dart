class User {
  String? id = '';
  String username;
  String email;
  String password;
  String usecurityQuestion;
  String uanswer;
  bool isAdmin;
  List<Map<String, dynamic>> ucart; // New field for cart items

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.usecurityQuestion,
    required this.uanswer,
    required this.isAdmin,
    this.ucart = const [], // Initialize ucart as an empty list by default
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['uname'],
      email: json['uemail'],
      password: json['upass'],
      usecurityQuestion: json['usecurityQuestion'] ?? '', // You can replace '' with a default value if needed
      uanswer: json['uanswer'] ?? '', // You can replace '' with a default value if needed
      isAdmin: json['isAdmin'] ?? false, // You can replace false with a default value if needed
      ucart: List<Map<String, dynamic>>.from(json['ucart'] ?? []), // Convert to list of maps
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uname': username,
      'uemail': email,
      'upass': password,
      'usecurityQuestion': usecurityQuestion,
      'uanswer': uanswer,
      'isAdmin': isAdmin,
      'ucart': ucart, // Add ucart to JSON
    };
  }
}
