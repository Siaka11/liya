import 'package:flutter/material.dart';

class PopularityBadge extends StatelessWidget {
  final int orderCount;
  final double rating;
  final int ratingCount;
  final bool showDetails;

  const PopularityBadge({
    super.key,
    required this.orderCount,
    required this.rating,
    required this.ratingCount,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    // Déterminer le niveau de popularité
    final PopularityLevel level = _getPopularityLevel();

    if (level == PopularityLevel.none && !showDetails) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: level.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: level.color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            level.icon,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            level.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showDetails) ...[
            const SizedBox(width: 4),
            Text(
              '($orderCount)',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  PopularityLevel _getPopularityLevel() {
    if (orderCount >= 50) {
      return PopularityLevel.trending;
    } else if (orderCount >= 20) {
      return PopularityLevel.popular;
    } else if (orderCount >= 5) {
      return PopularityLevel.liked;
    } else if (rating >= 4.5 && ratingCount >= 3) {
      return PopularityLevel.topRated;
    } else {
      return PopularityLevel.none;
    }
  }
}

enum PopularityLevel {
  none(Colors.transparent, Icons.circle, ''),
  liked(Colors.orange, Icons.thumb_up, 'Apprécié'),
  popular(Colors.red, Icons.local_fire_department, 'Populaire'),
  trending(Colors.purple, Icons.trending_up, 'Tendance'),
  topRated(Colors.green, Icons.star, 'Top Noté');

  const PopularityLevel(this.color, this.icon, this.label);

  final Color color;
  final IconData icon;
  final String label;
}
