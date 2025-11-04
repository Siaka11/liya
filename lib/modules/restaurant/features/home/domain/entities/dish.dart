class Dish {
  final String id;
  final String name;
  final String price;
  final String imageUrl;
  final String restaurantId;
  final String description;
  final String category;
  final String preparationTime;
  final bool isAvailable;
  final double rating;
  final int ratingCount;
  final int orderCount;
  final int viewCount;
  final double popularityScore;
  final DateTime? lastOrdered;
  final DateTime? lastViewed;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int sodas;
  final List<String> supplements;
  final List<String> allergens;
  final Map<String, dynamic> nutritionalInfo;
  final List<String> tags;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final bool isSpicy;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  Dish({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.restaurantId,
    required this.description,
    this.category = '',
    this.preparationTime = '',
    this.isAvailable = true,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.orderCount = 0,
    this.viewCount = 0,
    this.popularityScore = 0.0,
    this.lastOrdered,
    this.lastViewed,
    this.createdAt,
    this.updatedAt,
    this.sodas = 0,
    this.supplements = const [],
    this.allergens = const [],
    this.nutritionalInfo = const {},
    this.tags = const [],
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.isSpicy = false,
    this.calories = 0,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
  });
}
