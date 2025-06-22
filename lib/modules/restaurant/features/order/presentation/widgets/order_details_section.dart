import 'package:flutter/material.dart';
import '../../domain/entities/order.dart';
import 'package:liya/core/distance_service.dart';

class OrderDetailsSection extends StatelessWidget {
  final Order order;
  const OrderDetailsSection({required this.order, Key? key}) : super(key: key);

  String get formattedOrderNumber {
    final date = order.createdAt;
    final idNum = order.id.replaceAll(RegExp(r'\D'), '');
    final suffix = idNum.isNotEmpty
        ? idNum
            .padLeft(5, '0')
            .substring(idNum.length > 5 ? idNum.length - 5 : 0)
        : '00001';
    return 'RESTO${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text('DETAILS DE LA COMMANDE',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
        ),

        // Informations de base
        _OrderDetailRow(
            label: 'Numéro de commande', value: formattedOrderNumber),
        _OrderDetailRow(
          label: 'Date de commande',
          value:
              '${order.createdAt.day.toString().padLeft(2, '0')}/${order.createdAt.month.toString().padLeft(2, '0')}/${order.createdAt.year}',
        ),

        // Informations de livraison
        if (order.address != null)
          _OrderDetailRow(label: 'Adresse de livraison', value: order.address!),

        if (order.distance != null)
          _OrderDetailRow(
            label: 'Distance',
            value: DistanceService.formatDistance(order.distance!),
          ),

        if (order.deliveryTime != null)
          _OrderDetailRow(
            label: 'Temps de livraison estimé',
            value: DistanceService.formatDeliveryTime(order.deliveryTime!),
          ),

        if (order.deliveryInstructions != null &&
            order.deliveryInstructions!.isNotEmpty)
          _OrderDetailRow(
            label: 'Instructions de livraison',
            value: order.deliveryInstructions!,
          ),

        const SizedBox(height: 16),

        // Section des prix
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DÉTAIL DES PRIX',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),

              // Sous-total
              _PriceRow(
                label: 'Sous-total',
                value: '${order.subtotal.toStringAsFixed(0)} FCFA',
                isTotal: false,
              ),

              // Frais de livraison
              _PriceRow(
                label: 'Frais de livraison',
                value: '${order.deliveryFee} FCFA',
                isTotal: false,
                valueColor: Colors.orange,
              ),

              const Divider(),
              const SizedBox(height: 8),

              // Total
              _PriceRow(
                label: 'Total',
                value: '${order.total.toStringAsFixed(0)} FCFA',
                isTotal: true,
                valueColor: Colors.green,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

class _OrderDetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _OrderDetailRow({required this.label, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.isTotal,
    this.valueColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
