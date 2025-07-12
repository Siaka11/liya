import 'dart:convert';

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../../core/local_storage_factory.dart';
import '../../../../../../core/singletons.dart';
import '../../../card/data/datasources/cart_remote_data_source.dart';
import '../../../card/data/models/cart_item_model.dart';
import '../../../card/domain/repositories/cart_repository.dart';
import '../../../card/domain/usecases/add_to_cart.dart';
// Import des nouveaux widgets modernes
import 'package:liya/modules/restaurant/features/order/presentation/widgets/floating_order_button.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/beverage_button.dart';
import 'package:liya/modules/restaurant/features/order/presentation/providers/modern_order_provider.dart';
import 'package:liya/modules/restaurant/features/order/domain/entities/beverage.dart';
import 'package:liya/modules/restaurant/features/like/presentation/widgets/like_button.dart';
import 'package:liya/routes/app_router.gr.dart';

@RoutePage(name: 'DishDetailRoute')
class DishDetailPage extends ConsumerStatefulWidget {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final String price;
  final String imageUrl;
  final String rating;

  const DishDetailPage({
    super.key,
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.description,
  });

  @override
  ConsumerState<DishDetailPage> createState() => _DishDetailPageState();
}

class _DishDetailPageState extends ConsumerState<DishDetailPage>
    with TickerProviderStateMixin {
  bool isLoading = true;
  List<BeverageSelection> selectedBeverages = [];
  List<Beverage> beverages = [];
  bool isBeveragesLoading = true;

  // Contrôleurs d'animation simplifiés
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _fetchBeverages();

    // Initialisation des contrôleurs d'animation simplifiés
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Démarrer les animations
    _fadeController.forward();
    _slideController.forward();

    // Écouter le scroll pour l'effet de parallaxe
    _scrollController.addListener(_onScroll);

    // Simuler un chargement
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  Future<void> _fetchBeverages() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('beverages')
        .where('isAvailable', isEqualTo: true)
        .get();
    setState(() {
      beverages =
          snapshot.docs.map((doc) => Beverage.fromJson(doc.data())).toList();
      isBeveragesLoading = false;
    });
  }

  String _generateItemKey() {
    if (selectedBeverages.isEmpty) return widget.id;
    final accompKey = selectedBeverages
        .map((a) => '${a.beverage.id}_${a.selectedSize}_${a.quantity}')
        .join('-');
    return '${widget.id}-$accompKey';
  }

  int _getCurrentQuantity(WidgetRef ref) {
    final orderState = ref.watch(modernOrderProvider);
    final item = orderState.items[widget.id];
    return item?.quantity ?? 0;
  }

  void _syncAccompaniments(WidgetRef ref) {
    ref.read(modernOrderProvider.notifier).updateAccompaniments(
          id: widget.id,
          accompaniments: List<BeverageSelection>.from(selectedBeverages),
        );
  }

  void _addBeverage(Beverage beverage, WidgetRef ref) {
    setState(() {
      final size = beverage.sizes.keys.isNotEmpty
          ? beverage.sizes.keys.first
          : 'default';
      final existing = selectedBeverages.indexWhere(
          (b) => b.beverage.id == beverage.id && b.selectedSize == size);
      if (existing >= 0) {
        selectedBeverages[existing] = BeverageSelection(
          beverage: beverage,
          selectedSize: size,
          quantity: selectedBeverages[existing].quantity + 1,
        );
      } else {
        selectedBeverages.add(BeverageSelection(
          beverage: beverage,
          selectedSize: size,
          quantity: 1,
        ));
      }
    });
    _syncAccompaniments(ref);
  }

  void _removeBeverage(Beverage beverage, WidgetRef ref) {
    setState(() {
      final size = beverage.sizes.keys.isNotEmpty
          ? beverage.sizes.keys.first
          : 'default';
      final existing = selectedBeverages.indexWhere(
          (b) => b.beverage.id == beverage.id && b.selectedSize == size);
      if (existing >= 0) {
        if (selectedBeverages[existing].quantity > 1) {
          selectedBeverages[existing] = BeverageSelection(
            beverage: beverage,
            selectedSize: size,
            quantity: selectedBeverages[existing].quantity - 1,
          );
        } else {
          selectedBeverages.removeAt(existing);
        }
      }
    });
    _syncAccompaniments(ref);
  }

  void _onAccompanimentChanged(
      WidgetRef ref, List<BeverageSelection> newSelection) {
    setState(() {
      selectedBeverages = List<BeverageSelection>.from(newSelection);
    });
    _syncAccompaniments(ref);
  }

  void _addCurrent(WidgetRef ref) {
    ref.read(modernOrderProvider.notifier).addItem(
          id: widget.id,
          name: widget.name,
          price: widget.price,
          imageUrl: widget.imageUrl,
          restaurantId: widget.restaurantId,
          description: widget.description,
          accompaniments: selectedBeverages,
        );
  }

  void _removeCurrent(WidgetRef ref) {
    ref.read(modernOrderProvider.notifier).removeItem(widget.id);
  }

  bool canModifyAccompaniments(WidgetRef ref) => _getCurrentQuantity(ref) > 0;

  @override
  Widget build(BuildContext context) {
    final modernQuantity = _getCurrentQuantity(ref);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: MediaQuery.of(context).size.height * 0.5,
                pinned: false,
                floating: false,
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.error, size: 300),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 120), // espace pour le bouton quantité
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contenu principal
                      _buildDishHeader(),
                      const SizedBox(height: 20),
                      if (!widget.description.isEmpty) ...[
                        _buildDescription(),
                      ],
                      const SizedBox(height: 24),
                      _buildAccompanimentsSection(ref),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Overlay des boutons retour et cœur sur l'image
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bouton de retour
                  CircleAvatar(
                    backgroundColor: Colors.white70,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Bouton cœur (like)
                  CircleAvatar(
                    backgroundColor: Colors.white70,
                    child: LikeButton(
                      dishId: widget.id,
                      userId: 'user_id', // À adapter selon votre logique
                      name: widget.name,
                      price: widget.price,
                      imageUrl: widget.imageUrl,
                      description: widget.description,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contrôle de quantité + Voir votre commande TOUJOURS visibles en bas
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            'Quantité',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove,
                                    color: Colors.white, size: 20),
                                onPressed: modernQuantity > 0
                                    ? () => _removeCurrent(ref)
                                    : null,
                              ),
                              Container(
                                width: 40,
                                alignment: Alignment.center,
                                child: Text(
                                  '$modernQuantity',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add,
                                    color: Colors.white, size: 20),
                                onPressed: () => _addCurrent(ref),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Voir votre commande (bouton flottant)
                  FloatingOrderButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.price} FCFA',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccompanimentsSection(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accompagnements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          isBeveragesLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: beverages.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final beverage = beverages[i];
                    final size = beverage.sizes.keys.isNotEmpty
                        ? beverage.sizes.keys.first
                        : 'default';
                    final price = beverage.sizes[size] ?? 0.0;
                    final selected = selectedBeverages.firstWhere(
                      (b) =>
                          b.beverage.id == beverage.id &&
                          b.selectedSize == size,
                      orElse: () => BeverageSelection(
                          beverage: beverage, selectedSize: size, quantity: 0),
                    );
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ListTile(
                        leading: beverage.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  beverage.imageUrl,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.local_drink,
                                color: Colors.orange, size: 32),
                        title: Text(
                          beverage.name + (size != 'default' ? ' $size' : ''),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '+${price.toStringAsFixed(2)} FCFA',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: canModifyAccompaniments(ref)
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                              onPressed: (canModifyAccompaniments(ref) &&
                                      selected.quantity > 0)
                                  ? () => _removeBeverage(beverage, ref)
                                  : null,
                            ),
                            Container(
                              width: 30,
                              alignment: Alignment.center,
                              child: Text(
                                '${selected.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add_circle,
                                color: canModifyAccompaniments(ref)
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                              onPressed: canModifyAccompaniments(ref)
                                  ? () => _addBeverage(beverage, ref)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

// Modèle pour un soda
class SodaSupplement {
  final String name;
  final bool active;
  final Map<String, String> sizes;

  SodaSupplement({
    required this.name,
    required this.active,
    required this.sizes,
  });

  factory SodaSupplement.fromJson(Map<String, dynamic> json) {
    return SodaSupplement(
      name: json['name'] ?? '',
      active: json['active'] ?? false,
      sizes: Map<String, String>.from(json['sizes'] ?? {}),
    );
  }
}

// Provider pour récupérer les sodas actifs
final sodasProvider = FutureProvider<List<SodaSupplement>>((ref) async {
  final doc = await FirebaseFirestore.instance
      .collection('supplements')
      .doc('global_sodas')
      .get();

  final sodasList = (doc.data()?['sodas'] as List<dynamic>? ?? []);
  return sodasList
      .map((e) => SodaSupplement.fromJson(Map<String, dynamic>.from(e)))
      .where((soda) => soda.active)
      .toList();
});
