import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'package:liya/modules/restaurant/features/like/presentation/widgets/like_button.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/floating_order_button.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/beverage_button.dart';
import 'package:liya/modules/restaurant/features/order/presentation/providers/modern_order_provider.dart';
import 'package:liya/modules/restaurant/features/order/domain/entities/beverage.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'package:liya/core/singletons.dart';
import 'dart:convert';

@RoutePage(name: 'ModernDishDetailRoute')
class ModernDishDetailPage extends ConsumerStatefulWidget {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final String price;
  final String imageUrl;
  final String rating;

  const ModernDishDetailPage({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.description,
  });

  @override
  ConsumerState<ModernDishDetailPage> createState() =>
      _ModernDishDetailPageState();
}

class _ModernDishDetailPageState extends ConsumerState<ModernDishDetailPage> {
  List<BeverageSelection> selectedBeverages = [];

  @override
  Widget build(BuildContext context) {
    final quantity = ref.watch(itemQuantityProvider(widget.id));
    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = (userDetails['phoneNumber'] ?? '').toString();

    return Scaffold(
      body: Stack(
        children: [
          // Image de couverture
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: Image.network(
                    widget.imageUrl,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.5,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error,
                          size: 100, color: Colors.grey),
                    ),
                  ),
                ),

                // Bouton de retour
                Positioned(
                  top: 50,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // Bouton like
                Positioned(
                  top: 60,
                  right: 16,
                  child: LikeButton(
                    dishId: widget.id,
                    userId: phoneNumber,
                    name: widget.name,
                    price: widget.price,
                    imageUrl: widget.imageUrl,
                    description: widget.description,
                  ),
                ),
              ],
            ),
          ),

          // Contenu principal
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.5),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom et prix du plat
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '${widget.price} FCFA',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: UIColors.orange,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Section boissons (compléments) : toujours affichée
                        BeverageButton(
                          selectedBeverages: selectedBeverages,
                          onBeveragesChanged: (beverages) {
                            setState(() {
                              selectedBeverages = beverages;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Contrôles de quantité
                        _buildQuantityControls(),

                        const SizedBox(
                            height: 100), // Espace pour le bouton flottant
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bouton flottant de commande
          FloatingOrderButton(
            restaurantName: null, // Pas de nom de restaurant sur cette page
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls() {
    final quantity = ref.watch(itemQuantityProvider(widget.id));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Titre
          const Text(
            'Quantité',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Contrôles de quantité
          Container(
            decoration: BoxDecoration(
              color: UIColors.orange,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white, size: 20),
                  onPressed: quantity > 0 ? () => _removeItem() : null,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  onPressed: () => _addItem(),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    ref.read(modernOrderProvider.notifier).addItem(
          id: widget.id,
          name: widget.name,
          price: widget.price,
          imageUrl: widget.imageUrl,
          restaurantId: widget.restaurantId,
          description: widget.description,
        );
  }

  void _removeItem() {
    ref.read(modernOrderProvider.notifier).removeItem(widget.id);
  }
}
