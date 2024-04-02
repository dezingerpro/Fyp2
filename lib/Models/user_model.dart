class User {
  String? id = '';
  String username;
  String email;
  String password;
  String mobileNumber; // New field
  String city; // New field
  String streetAddress; // New field
  String houseDetails; // New field
  String usecurityQuestion;
  String uanswer;
  bool isAdmin;
  List<Map<String, dynamic>> ucart;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.mobileNumber, // Initialize the new field
    required this.city, // Initialize the new field
    required this.streetAddress, // Initialize the new field
    required this.houseDetails, // Initialize the new field
    required this.usecurityQuestion,
    required this.uanswer,
    required this.isAdmin,
    this.ucart = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['uname'],
      email: json['uemail'],
      password: json['upass'],
      mobileNumber: json['umobile'] ?? '', // Default value if not found
      city: json['ucity'] ?? '', // Default value if not found
      streetAddress: json['ustreet'] ?? '', // Default value if not found
      houseDetails: json['uhouse'] ?? '', // Default value if not found
      usecurityQuestion: json['usecurityQuestion'] ?? '',
      uanswer: json['uanswer'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      ucart: List<Map<String, dynamic>>.from(json['ucart'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Make sure to include the ID if you want it serialized
      'uname': username,
      'uemail': email,
      'upass': password,
      'umobile': mobileNumber, // Serialize the new field
      'ucity': city, // Serialize the new field
      'ustreet': streetAddress, // Serialize the new field
      'uhouse': houseDetails, // Serialize the new field
      'usecurityQuestion': usecurityQuestion,
      'uanswer': uanswer,
      'isAdmin': isAdmin,
      'ucart': ucart,
    };
  }
}
