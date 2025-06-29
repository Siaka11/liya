import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/theme/theme.dart';
import '../../domain/entities/beverage.dart';
import 'beverage_selector.dart';

class BeverageButton extends ConsumerWidget {
  final List<BeverageSelection> selectedBeverages;
  final Function(List<BeverageSelection>) onBeveragesChanged;

  const BeverageButton({
    Key? key,
    required this.selectedBeverages,
    required this.onBeveragesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalItems =
        selectedBeverages.fold(0, (sum, selection) => sum + selection.quantity);
    final totalPrice = selectedBeverages.fold(
        0.0, (sum, selection) => sum + selection.totalPrice);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showBeverageSelector(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedBeverages.isNotEmpty
                    ? UIColors.orange
                    : Colors.grey[300]!,
                width: selectedBeverages.isNotEmpty ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icône de boisson
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: UIColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_drink,
                    color: UIColors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Informations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Ajouter des boissons',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (totalItems > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: UIColors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$totalItems',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (selectedBeverages.isNotEmpty) ...[
                        Text(
                          selectedBeverages
                              .map((s) => s.displayName)
                              .join(', '),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+${totalPrice.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: UIColors.orange,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Sodas, eau, jus...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Flèche
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBeverageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => BeverageSelector(
          initialSelections: selectedBeverages,
          onBeveragesSelected: onBeveragesChanged,
        ),
      ),
    );
  }
}
