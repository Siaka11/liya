

class User {
  final String name;
  final String lastName;
  final String? role; // Champ optionnel pour le rôle
  final String? email; // Champ optionnel pour l'email

  const User({
    required this.name,
    required this.lastName,
    this.role,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastName': lastName,
      'role': role,
      'email': email,
    };
  }
}