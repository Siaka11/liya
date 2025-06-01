import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/category_provider.dart';
import '../../domain/entities/dish.dart';
import 'package:liya/modules/restaurant/features/home/presentation/widget/dish_card.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/dish_detail_page.dart';
import 'package:liya/core/ui/theme/theme.dart';

class DishesByCategoryPage extends ConsumerWidget {
  final String categoryName;
  const DishesByCategoryPage({Key? key, required this.categoryName})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishesAsync = ref.watch(dishesByCategoryProvider(categoryName));
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: dishesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (dishes) => ListView.builder(
          itemCount: dishes.length,
          itemBuilder: (context, index) {
            final Dish dish = dishes[index];
            return DishCard(
              name: dish.name,
              price: dish.price,
              imageUrl: dish.imageUrl,
              description: dish.description,
              quantity: 0,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DishDetailPage(
                      id: dish.id,
                      restaurantId: '', // Pas dispo côté catégorie
                      name: dish.name,
                      price: dish.price,
                      imageUrl: dish.imageUrl,
                      rating: '0.0', // Pas dispo côté catégorie
                      description: dish.description,
                      sodas: dish.sodas,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
