import 'package:flutter/material.dart';

class PromotionBadge extends StatelessWidget {
  final double discountPercentage;
  final bool isOnSale;
  final double? originalPrice;
  final double? currentPrice;

  const PromotionBadge({
    Key? key,
    this.discountPercentage = 0.0,
    this.isOnSale = false,
    this.originalPrice,
    this.currentPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isOnSale || discountPercentage <= 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_offer,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 2),
            Text(
              '-${discountPercentage.toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PriceDisplay extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final bool isOnSale;

  const PriceDisplay({
    Key? key,
    required this.price,
    this.originalPrice,
    this.isOnSale = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isOnSale || originalPrice == null || originalPrice! <= price) {
      return Text(
        '${price.toInt()} CFA',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${originalPrice!.toInt()} CFA',
          style: const TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        Text(
          '${price.toInt()} CFA',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
