class Beverage {
  final String id;
  final String name;
  final String imageUrl;
  final String category; // 'soda', 'water', 'juice', etc.
  final Map<String, double> sizes; // 'small': 300, 'medium': 500, 'large': 800
  final bool isAvailable;
  final String description;

  Beverage({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.sizes,
    required this.isAvailable,
    required this.description,
  });

  factory Beverage.fromJson(Map<String, dynamic> json) {
    final rawSizes = json['sizes'] ?? {};
    final Map<String, double> parsedSizes = {};
    rawSizes.forEach((key, value) {
      if (value is int) {
        parsedSizes[key] = value.toDouble();
      } else if (value is double) {
        parsedSizes[key] = value;
      } else {
        parsedSizes[key] = double.tryParse(value.toString()) ?? 0.0;
      }
    });
    return Beverage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'soda',
      sizes: parsedSizes,
      isAvailable: json['isAvailable'] ?? true,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'category': category,
      'sizes': sizes,
      'isAvailable': isAvailable,
      'description': description,
    };
  }
}

class BeverageSelection {
  final Beverage beverage;
  final String selectedSize;
  final int quantity;

  BeverageSelection({
    required this.beverage,
    required this.selectedSize,
    required this.quantity,
  });

  double get totalPrice {
    final sizePrice = beverage.sizes[selectedSize] ?? 0.0;
    return sizePrice * quantity;
  }

  String get displayName {
    return '${beverage.name} (${selectedSize})';
  }
}
