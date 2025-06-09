class RestaurantModel {
  final String id;
  final String name;
  // Ajoute d'autres champs si besoin

  RestaurantModel({required this.id, required this.name});

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
    );
  }
}
