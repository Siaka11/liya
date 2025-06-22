import 'package:flutter/material.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'package:liya/core/distance_service.dart';

class DistanceInfoWidget extends StatelessWidget {
  final double? distance;
  final int? deliveryTime;
  final String? address;

  const DistanceInfoWidget({
    Key? key,
    this.distance,
    this.deliveryTime,
    this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: UIColors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Informations de livraison',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (address != null) ...[
            Row(
              children: [
                Icon(
                  Icons.place,
                  color: Colors.grey.shade600,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Icon(
                Icons.straighten,
                color: Colors.grey.shade600,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Distance: ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                distance != null
                    ? DistanceService.formatDistance(distance!)
                    : 'Calcul...',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: UIColors.orange,
                ),
              ),
            ],
          ),
          if (deliveryTime != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.grey.shade600,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Temps estimé: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  DistanceService.formatDeliveryTime(deliveryTime!),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: UIColors.orange,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
