import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/all_dishes_provider.dart';
import '../widget/popular_dish_card.dart';

@RoutePage()
class AllDishesPage extends ConsumerWidget {
  const AllDishesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishesAsync = ref.watch(allDishesProvider);
    final userId = ""; // À remplacer par la vraie logique utilisateur si besoin

    return Scaffold(
      appBar: AppBar(title: const Text("Tous les plats")),
      body: dishesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (dishes) => ListView.builder(
          itemCount: dishes.length,
          itemBuilder: (context, index) {
            final dish = dishes[index];
            return PopularDishCard(
              id: dish.id,
              name: dish.name,
              price: dish.price,
              imageUrl: dish.imageUrl,
              restaurantId: dish.restaurantId,
              description: dish.description,
              userId: userId,
              sodas: dish.sodas,
              onAddToCart:
                  () {}, // À remplacer par la vraie logique d'ajout au panier
            );
          },
        ),
      ),
    );
  }
}
