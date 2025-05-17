import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:liya/core/ui/theme/theme.dart';

import '../../application/dish_provider.dart';
import '../widget/dish_card.dart';

@RoutePage(name: 'RestaurantDetailRoute')
class RestaurantDetailPage extends ConsumerWidget {
  final String id;
  final String name;
  final String description;

  const RestaurantDetailPage({
    super.key,
    required this.id,
    required this.name,
    required this.description,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishController = ref.read(dishControllerProvider(id).notifier);
    final dishState = ref.watch(dishControllerProvider(id));

    // Charger les plats au premier rendu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dishState.dishes == null && !dishState.isLoading) {
        dishController.loadDishes(id);
      }
    });

    return Scaffold(
      backgroundColor: UIColors.defaultColor,
      body: Stack(
        children: [
          // Arrière-plan avec l'image du restaurant
          Container(
            height: 300, // Réduire la hauteur car le texte n'est plus dessus
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/basi.jpg'), // Utilisation de l'image statique
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Contenu principal
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Espace pour l'image d'arrière-plan
                SizedBox(
                    height: 300), // Espace pour l'image et le bouton de retour
                // Section blanche arrondie avec toutes les informations
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(60)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom du restaurant
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        // Temps de livraison
                        Row(
                          children: [
                            Icon(Icons.local_shipping,
                                color: Colors.grey, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Livraison 25-35 min',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        // Description
                        Text(
                          description,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 8),
                        // Liste des plats
                        Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Plats disponibles',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        dishState.isLoading
                            ? Center(child: CircularProgressIndicator())
                            : dishState.error != null
                                ? Center(child: Text(dishState.error!))
                                : dishState.dishes == null ||
                                        dishState.dishes!.isEmpty
                                    ? Center(
                                        child: Text(
                                            "Aucun plat disponible pour ce restaurant"))
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: dishState.dishes!.length,
                                        itemBuilder: (context, index) {
                                          final dish = dishState.dishes![index];
                                          return DishCard(
                                            name: dish.name,
                                            price: dish.price,
                                            // originalPrice: '6000 CFA', // Exemple
                                            //discount: '-35%', // Exemple
                                            imageUrl: dish.imageUrl,
                                            description: dish.description ?? '',
                                            onAddToCart: () {
                                              print(
                                                  "Ajouté au panier : ${dish.name} (Restaurant: $id)");
                                            },
                                          );
                                        },
                                      ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bouton de retour
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.7),
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
