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

class _DishDetailPageState extends ConsumerState<DishDetailPage> {
  bool isLoading = true;
  List<BeverageSelection> selectedBeverages = [];
  List<Beverage> beverages = [];
  bool isBeveragesLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBeverages();
    // Simuler un chargement
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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

        return Scaffold(
          body: Stack(
            children: [
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image avec superposition des éléments
                        Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(20)),
                                child: Image.network(
                                  widget.imageUrl,
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.error, size: 300),
                                ),
                              ),
                              Positioned(
                                top: 50,
                                left: 16,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: IconButton(
                                    color: Colors.white,
                                    icon: Icon(Icons.arrow_back,
                                        color: Colors.white),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.name,
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      Text('${widget.price} CFA',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    widget.description,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey[700]),
                                  ),
                                  // Section accompagnements (boissons)
                                  SizedBox(height: 24),
                                  Text(
                                    'Accompagnements',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  isBeveragesLoading
                                      ? Center(
                                          child: CircularProgressIndicator())
                                      : ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemCount: beverages.length,
                                          separatorBuilder: (context, i) =>
                                              SizedBox(height: 8),
                                          itemBuilder: (context, i) {
                                            final beverage = beverages[i];
                                            final size =
                                                beverage.sizes.keys.isNotEmpty
                                                    ? beverage.sizes.keys.first
                                                    : 'default';
                                            final price =
                                                beverage.sizes[size] ?? 0.0;
                                            final selected =
                                                selectedBeverages.firstWhere(
                                              (b) =>
                                                  b.beverage.id ==
                                                      beverage.id &&
                                                  b.selectedSize == size,
                                              orElse: () => BeverageSelection(
                                                  beverage: beverage,
                                                  selectedSize: size,
                                                  quantity: 0),
                                            );
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.grey[200]!,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.03),
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: ListTile(
                                                leading: beverage
                                                        .imageUrl.isNotEmpty
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        child: Image.network(
                                                          beverage.imageUrl,
                                                          width: 40,
                                                          height: 40,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : Icon(Icons.local_drink,
                                                        color: Colors.orange,
                                                        size: 32),
                                                title: Text(
                                                  beverage.name +
                                                      (size != 'default'
                                                          ? ' $size'
                                                          : ''),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                subtitle: Text(
                                                  '+${price.toStringAsFixed(2)} FCFA',
                                                  style: TextStyle(
                                                      color: Colors.grey[600]),
                                                ),
                                                trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    if (selected.quantity >
                                                        0) ...[
                                                      IconButton(
                                                        icon: Icon(
                                                            Icons
                                                                .remove_circle_outline,
                                                            color:
                                                                canModifyAccompaniments(
                                                                        ref)
                                                                    ? Colors
                                                                        .orange
                                                                    : Colors
                                                                        .grey),
                                                        onPressed:
                                                            canModifyAccompaniments(
                                                                    ref)
                                                                ? () =>
                                                                    _removeBeverage(
                                                                        beverage,
                                                                        ref)
                                                                : null,
                                                      ),
                                                      Text(
                                                          '${selected.quantity}',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .orange)),
                                                    ],
                                                    IconButton(
                                                      icon: Icon(
                                                          Icons.add_circle,
                                                          color:
                                                              canModifyAccompaniments(
                                                                      ref)
                                                                  ? Colors
                                                                      .orange
                                                                  : Colors
                                                                      .grey),
                                                      onPressed:
                                                          canModifyAccompaniments(
                                                                  ref)
                                                              ? () =>
                                                                  _addBeverage(
                                                                      beverage,
                                                                      ref)
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
                            ),
                          ),
                        ),
                        // Nouveau système de contrôles de quantité
                        Container(
                          padding: EdgeInsets.all(16),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove),
                                            onPressed: modernQuantity > 0
                                                ? () => _removeCurrent(ref)
                                                : null,
                                          ),
                                          Text(
                                            '$modernQuantity',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.add),
                                            onPressed: () => _addCurrent(ref),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                            height: 100), // Espace pour le bouton flottant
                      ],
                    ),

              // Bouton flottant de commande moderne
              const FloatingOrderButton(),
            ],
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
