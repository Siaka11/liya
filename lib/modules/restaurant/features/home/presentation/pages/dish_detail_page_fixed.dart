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

  // Contrôleurs d'animation
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  double _imageHeight = 0;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _fetchBeverages();

    // Initialisation des contrôleurs d'animation
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Démarrer les animations
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);

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
    _pulseController.dispose();
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
    return Consumer(
      builder: (context, ref, child) {
        final orderState = ref.watch(modernOrderProvider);
        final item = orderState.items[widget.id];

        // Si le plat n'est plus dans la commande, on vide la sélection locale
        if (item == null && selectedBeverages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              selectedBeverages.clear();
            });
          });
        }

        final modernQuantity = _getCurrentQuantity(ref);
        _imageHeight = MediaQuery.of(context).size.height * 0.5;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        // Image de couverture avec effet de parallaxe
                        _buildParallaxImage(),

                        // Contenu principal avec scroll animé
                        Expanded(
                          child: _buildScrollableContent(ref, modernQuantity),
                        ),
                      ],
                    ),

              // Boutons de navigation
              _buildNavigationButtons(),

              // Bouton de quantité fixe en bas
              _buildFixedQuantityButton(modernQuantity, ref),

              // Bouton flottant de commande moderne
              Positioned(
                bottom: 100, // Au-dessus du bouton de quantité
                left: 20,
                right: 20,
                child: FloatingOrderButton(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParallaxImage() {
    return Container(
      height: _imageHeight,
      width: double.infinity,
      child: Stack(
        children: [
          // Image avec effet de parallaxe
          Positioned(
            top: -_scrollOffset * 0.6,
            left: 0,
            right: 0,
            height: _imageHeight + (_scrollOffset * 0.6),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(_scrollOffset > 0 ? 0 : 25),
              ),
              child: Image.network(
                widget.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.error, size: 300),
              ),
            ),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bouton de retour avec animation
            AnimatedOpacity(
              opacity: _scrollOffset > 50 ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            // Bouton like
            LikeButton(
              dishId: widget.id,
              userId: 'user_id', // À adapter selon votre logique
              name: widget.name,
              price: widget.price,
              imageUrl: widget.imageUrl,
              description: widget.description,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent(WidgetRef ref, int modernQuantity) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contenu principal avec animations
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête du plat avec animation
                        _buildDishHeader(),

                        const SizedBox(height: 20),

                        // Description avec animation
                        _buildDescription(),

                        const SizedBox(height: 24),

                        // Section accompagnements avec animation
                        _buildAccompanimentsSection(ref),

                        const SizedBox(
                            height: 120), // Espace pour les boutons en bas
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDishHeader() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade50, Colors.orange.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.shade200, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
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
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '${widget.price} FCFA',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.6,
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
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_drink, color: Colors.green.shade700, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Accompagnements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
                            if (selected.quantity > 0) ...[
                              _buildAnimatedButton(
                                icon: Icons.remove_circle_outline,
                                onPressed: canModifyAccompaniments(ref)
                                    ? () => _removeBeverage(beverage, ref)
                                    : null,
                                isEnabled: canModifyAccompaniments(ref),
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
                            ],
                            _buildAnimatedButton(
                              icon: Icons.add_circle,
                              onPressed: canModifyAccompaniments(ref)
                                  ? () => _addBeverage(beverage, ref)
                                  : null,
                              isEnabled: canModifyAccompaniments(ref),
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

  Widget _buildFixedQuantityButton(int modernQuantity, WidgetRef ref) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Titre
                  const Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: Text(
                      'Quantité',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Contrôles de quantité avec animations
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bouton moins avec animation
                        _buildAnimatedButton(
                          icon: Icons.remove,
                          onPressed: modernQuantity > 0
                              ? () => _removeCurrent(ref)
                              : null,
                          isEnabled: modernQuantity > 0,
                        ),

                        // Quantité avec animation
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Container(
                            key: ValueKey(modernQuantity),
                            width: 50,
                            alignment: Alignment.center,
                            child: Text(
                              '$modernQuantity',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),

                        // Bouton plus avec animation
                        _buildAnimatedButton(
                          icon: Icons.add,
                          onPressed: () => _addCurrent(ref),
                          isEnabled: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 1.0, end: isEnabled ? 1.0 : 0.5),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isEnabled
                  ? Colors.white.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              onPressed: onPressed,
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
            ),
          ),
        );
      },
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
