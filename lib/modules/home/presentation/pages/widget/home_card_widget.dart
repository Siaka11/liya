import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/ui/theme/theme.dart';
import '../../../domain/entities/home_option.dart';

IconData _mapIconStringToIconData(String icon) {
  switch (icon) {
    case 'fastfood':
      return Icons.fastfood;
    case 'local_shipping':
      return Icons.local_shipping;
    case 'delivery_dining':
      return Icons.delivery_dining;
    case 'shopping_cart':
      return Icons.shopping_cart;
    case 'admin_panel_settings':
      return Icons.admin_panel_settings;
    default:
      return Icons.help;
  }
}

class HomeOptionCard extends StatelessWidget {
  final HomeOption option;
  final VoidCallback onTap;

  const HomeOptionCard({
    super.key,
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: UIColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0.1,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône
              Icon(
                _mapIconStringToIconData(option.icon),
                size: 28,
                color: UIColors.orange,
              ),
              const SizedBox(height: 5),
              // Titre principal
              Text(
                option.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: UIColors.orange,
                ),
              ),
              const SizedBox(height: 5),
              // Texte secondaire (Ouvert tous les jours)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    option.availability,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              // Localisation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 14,
                    color: UIColors.grey,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    option.location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: UIColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
