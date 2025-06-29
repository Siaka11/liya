class CartItem {
  final String id;
  final String name;
  final String price;
  final String imageUrl;
  final String restaurantId;
  final String user;
  final String description;
  final String rating;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.restaurantId,
    required this.user,
    required this.description,
    required this.rating,
    required this.quantity,
  });
}
