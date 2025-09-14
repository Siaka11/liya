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
              const SizedBox(height: 20),
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
            ],
          ),
        ),
      ),
    );
  }
}
