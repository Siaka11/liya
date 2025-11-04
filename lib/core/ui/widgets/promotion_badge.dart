import 'package:flutter/material.dart';

class PromotionBadge extends StatelessWidget {
  final double discountPercentage;
  final double? discountAmount;
  final String? promotionTitle;
  final bool isLarge;
  final Color? backgroundColor;
  final Color? textColor;

  const PromotionBadge({
    Key? key,
    required this.discountPercentage,
    this.discountAmount,
    this.promotionTitle,
    this.isLarge = false,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.red;
    final txtColor = textColor ?? Colors.white;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 8 : 6,
        vertical: isLarge ? 4 : 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isLarge ? 12 : 8),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer,
            color: txtColor,
            size: isLarge ? 16 : 12,
          ),
          const SizedBox(width: 4),
          Text(
            _getDisplayText(),
            style: TextStyle(
              color: txtColor,
              fontSize: isLarge ? 12 : 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayText() {
    if (promotionTitle != null && promotionTitle!.isNotEmpty) {
      return promotionTitle!;
    }

    if (discountPercentage > 0) {
      return '-${discountPercentage.toInt()}%';
    }

    if (discountAmount != null && discountAmount! > 0) {
      return '-${discountAmount!.toInt()} CFA';
    }

    return 'PROMO';
  }
}

class PriceDisplay extends StatelessWidget {
  final double originalPrice;
  final double? currentPrice;
  final double? discountPercentage;
  final bool showPromotionBadge;
  final TextStyle? originalPriceStyle;
  final TextStyle? currentPriceStyle;

  const PriceDisplay({
    Key? key,
    required this.originalPrice,
    this.currentPrice,
    this.discountPercentage,
    this.showPromotionBadge = true,
    this.originalPriceStyle,
    this.currentPriceStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasDiscount = currentPrice != null && currentPrice! < originalPrice;
    final finalPrice = currentPrice ?? originalPrice;
    final discount = discountPercentage ??
        (hasDiscount
            ? ((originalPrice - finalPrice) / originalPrice) * 100
            : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasDiscount) ...[
          Text(
            '${originalPrice.toInt()} CFA',
            style: (originalPriceStyle ?? const TextStyle()).copyWith(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          '${finalPrice.toInt()} CFA',
          style: currentPriceStyle ??
              const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: hasDiscount ? Colors.red : Colors.black,
              ),
        ),
        if (showPromotionBadge && hasDiscount) ...[
          const SizedBox(width: 8),
          PromotionBadge(
            discountPercentage: discount,
            isLarge: false,
          ),
        ],
      ],
    );
  }
}

class PromotionCard extends StatelessWidget {
  final Map<String, dynamic> promotion;
  final VoidCallback? onTap;
  final bool isSelected;

  const PromotionCard({
    Key? key,
    required this.promotion,
    this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF24E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFF24E1E) : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_offer,
                  color: isSelected ? Colors.white : const Color(0xFFF24E1E),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    promotion['title'] ?? 'Promotion',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              promotion['description'] ?? '',
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey[600],
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : const Color(0xFFF24E1E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getDiscountText(),
                    style: TextStyle(
                      color:
                          isSelected ? const Color(0xFFF24E1E) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                if (promotion['end_date'] != null)
                  Text(
                    _getTimeRemaining(),
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDiscountText() {
    final discountType = promotion['discount_type'];
    final discountValue = promotion['discount_value'];

    if (discountType == 'percentage') {
      return '-${discountValue.toInt()}%';
    } else if (discountType == 'fixed_amount') {
      return '-${discountValue.toInt()} CFA';
    }
    return 'PROMO';
  }

  String _getTimeRemaining() {
    final endDate = promotion['end_date'];
    if (endDate == null) return '';

    final now = DateTime.now();
    final end = endDate.toDate();
    final difference = end.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}j restant';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h restant';
    } else {
      return 'Expire bientôt';
    }
  }
}
