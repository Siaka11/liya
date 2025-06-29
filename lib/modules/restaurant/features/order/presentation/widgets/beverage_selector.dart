import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/theme/theme.dart';
import '../../domain/entities/beverage.dart';
import '../providers/beverage_provider.dart';

class BeverageSelector extends ConsumerStatefulWidget {
  final Function(List<BeverageSelection>) onBeveragesSelected;
  final List<BeverageSelection> initialSelections;

  const BeverageSelector({
    Key? key,
    required this.onBeveragesSelected,
    this.initialSelections = const [],
  }) : super(key: key);

  @override
  ConsumerState<BeverageSelector> createState() => _BeverageSelectorState();
}

class _BeverageSelectorState extends ConsumerState<BeverageSelector>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, BeverageSelection> _selections = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialiser les sélections existantes
    for (final selection in widget.initialSelections) {
      _selections[selection.beverage.id] = selection;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header avec titre et bouton fermer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Choisissez vos boissons',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),

          // Tabs pour les catégories
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: UIColors.orange,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: UIColors.orange,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Sodas'),
                Tab(text: 'Eau'),
                Tab(text: 'Jus'),
              ],
            ),
          ),

          // Contenu des tabs
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBeverageList('soda'),
                _buildBeverageList('water'),
                _buildBeverageList('juice'),
              ],
            ),
          ),

          // Bouton de confirmation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: ${_getTotalPrice().toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: UIColors.orange,
                        ),
                      ),
                      Text(
                        '${_getTotalItems()} article(s) sélectionné(s)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _selections.isNotEmpty
                      ? () {
                          widget
                              .onBeveragesSelected(_selections.values.toList());
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirmer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeverageList(String category) {
    final beverages = ref.watch(beveragesByCategoryProvider(category));

    if (beverages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Aucune boisson disponible',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: beverages.length,
      itemBuilder: (context, index) {
        final beverage = beverages[index];
        return _BeverageCard(
          beverage: beverage,
          selection: _selections[beverage.id],
          onSelectionChanged: (selection) {
            setState(() {
              if (selection != null) {
                _selections[beverage.id] = selection;
              } else {
                _selections.remove(beverage.id);
              }
            });
          },
        );
      },
    );
  }

  double _getTotalPrice() {
    return _selections.values
        .fold(0.0, (sum, selection) => sum + selection.totalPrice);
  }

  int _getTotalItems() {
    return _selections.values
        .fold(0, (sum, selection) => sum + selection.quantity);
  }
}

class _BeverageCard extends StatefulWidget {
  final Beverage beverage;
  final BeverageSelection? selection;
  final Function(BeverageSelection?) onSelectionChanged;

  const _BeverageCard({
    required this.beverage,
    required this.selection,
    required this.onSelectionChanged,
  });

  @override
  State<_BeverageCard> createState() => _BeverageCardState();
}

class _BeverageCardState extends State<_BeverageCard> {
  String _selectedSize = 'medium';
  int _quantity = 0;

  @override
  void initState() {
    super.initState();
    if (widget.selection != null) {
      _selectedSize = widget.selection!.selectedSize;
      _quantity = widget.selection!.quantity;
    } else {
      _selectedSize = widget.beverage.sizes.keys.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizePrice = widget.beverage.sizes[_selectedSize] ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _quantity > 0 ? UIColors.orange : Colors.grey[200]!,
          width: _quantity > 0 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Image de la boisson
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.beverage.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.local_drink, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Informations de la boisson
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.beverage.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.beverage.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Sélection de la taille
            Text(
              'Choisissez la taille:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: widget.beverage.sizes.entries.map((entry) {
                final size = entry.key;
                final price = entry.value;
                final isSelected = _selectedSize == size;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSize = size;
                    });
                    _updateSelection();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? UIColors.orange : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? UIColors.orange : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      '${size.toUpperCase()} - ${price.toStringAsFixed(0)} FCFA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Contrôles de quantité
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantité:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 0
                          ? () {
                              setState(() {
                                _quantity--;
                              });
                              _updateSelection();
                            }
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: UIColors.orange,
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                        _updateSelection();
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      color: UIColors.orange,
                    ),
                  ],
                ),
              ],
            ),

            if (_quantity > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: UIColors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sous-total:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${(_quantity * sizePrice).toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: UIColors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _updateSelection() {
    if (_quantity > 0) {
      final selection = BeverageSelection(
        beverage: widget.beverage,
        selectedSize: _selectedSize,
        quantity: _quantity,
      );
      widget.onSelectionChanged(selection);
    } else {
      widget.onSelectionChanged(null);
    }
  }
}
