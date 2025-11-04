class SearchResult {
  final String id; // Changé de int à String pour Firestore
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  final String restaurantId;
  final String type; // Nouveau: 'dish', 'restaurant', 'category'
  final String category; // Nouveau: catégorie du plat/restaurant
  final String restaurantName; // Nouveau: nom du restaurant

  SearchResult({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.restaurantId,
    required this.type,
    required this.category,
    required this.restaurantName,
  });
}
