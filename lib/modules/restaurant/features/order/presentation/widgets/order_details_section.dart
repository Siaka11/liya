import 'package:flutter/material.dart';
import '../../domain/entities/order.dart';

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
        _OrderDetailRow(label: 'Numéro de commande', value: formattedOrderNumber),
        _OrderDetailRow(
          label: 'Date de commande',
          value:
              '${order.createdAt.day.toString().padLeft(2, '0')}/${order.createdAt.month.toString().padLeft(2, '0')}/${order.createdAt.year}',
        ),
        // Ajoute d'autres infos si besoin
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
