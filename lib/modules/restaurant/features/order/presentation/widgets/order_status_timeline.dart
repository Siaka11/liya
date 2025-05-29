import 'package:flutter/material.dart';
import '../../domain/entities/order.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderStatus status;
  final DateTime expectedDate;
  const OrderStatusTimeline(
      {required this.status, required this.expectedDate, Key? key})
      : super(key: key);

  int get statusIndex {
    switch (status) {
      case OrderStatus.reception:
        return 0;
      case OrderStatus.enRoute:
        return 1;
      case OrderStatus.livre:
      case OrderStatus.nonLivre:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFFA500);
    const grey = Color(0xFFE0E0E0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_statusTitle(status),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
          const SizedBox(height: 24),
          _TimelineStep(
            icon: Icons.inventory_2,
            label: 'RECEPTION',
            description: null,
            active: statusIndex >= 0,
            color: statusIndex >= 0 ? orange : Colors.black,
          ),
          _VerticalLine(color: statusIndex >= 1 ? orange : grey),
          _TimelineStep(
            icon: Icons.local_shipping,
            label: 'VOTRE LIVREUR EST ROUTE',
            description:
                "Vous pouvez suivre votre livreur sur la carte",
            active: statusIndex >= 1,
            color: statusIndex >= 1 ? orange : Colors.black,
          ),
          _VerticalLine(color: statusIndex >= 2 ? orange : grey),
          _TimelineStep(
            icon: Icons.inbox,
            label: 'COMMANDE LIVRÉE',
            description: _formatDate(expectedDate),
            active: statusIndex >= 2,
            color: statusIndex >= 2 ? orange : Colors.black,
            isDelivery: true,
          ),
        ],
      ),
    );
  }

  String _statusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.reception:
        return "VOTRE COMMANDE EST PRIS EN COMPTE";
      case OrderStatus.enRoute:
        return "VOTRE LIVREUR EST ROUTE";
      case OrderStatus.livre:
        return "COMMANDE LIVRÉE";
      case OrderStatus.nonLivre:
        return "COMMANDE NON LIVRÉE";
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      "JANVIER",
      "FEVRIER",
      "MARS",
      "AVRIL",
      "MAI",
      "JUIN",
      "JUILLET",
      "AOÛT",
      "SEPTEMBRE",
      "OCTOBRE",
      "NOVEMBRE",
      "DECEMBRE"
    ];
    return 'JOUR, ${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';
  }
}

class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? description;
  final bool active;
  final bool isDelivery;
  final Color color;
  const _TimelineStep(
      {required this.icon,
      required this.label,
      this.description,
      required this.active,
      this.isDelivery = false,
      required this.color,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: active ? color : Colors.white,
            border: Border.all(color: color, width: 2),
            shape: BoxShape.circle,
          ),
          width: 24,
          height: 24,
          child: Icon(icon, color: active ? Colors.white : color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: isDelivery ? 16 : 14)),
              if (description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(description!,
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerticalLine extends StatelessWidget {
  final Color color;
  const _VerticalLine({required this.color, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 11, top: 0, bottom: 0),
      height: 28,
      width: 2,
      color: color,
    );
  }
}
