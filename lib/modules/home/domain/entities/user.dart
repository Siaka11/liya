class User {
  final String name;
  final String lastName;
  final String? role; // Champ optionnel pour le rôle
  final String? email; // Champ optionnel pour l'email
  final String?
      phoneNumber; // Numéro de téléphone utilisé pour l'authentification

  const User({
    required this.name,
    required this.lastName,
    this.role,
    this.email,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastName': lastName,
      'role': role,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}
