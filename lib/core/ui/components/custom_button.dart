import 'package:flutter/material.dart';

import '../theme/theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double borderRadius; // Corrigé : "Raduis" → "Radius"
  final VoidCallback? onPressedButton;
  final Color? bgColor;
  final double fontSize;
  final double paddingVertical;

  const CustomButton({
    super.key,
    required this.text,
    required this.borderRadius,
    this.onPressedButton,
    this.bgColor,
    required this.fontSize,
    required this.paddingVertical
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressedButton,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor ?? UIColors.defaultColor,
        padding: EdgeInsets.symmetric(
          vertical: paddingVertical,
          horizontal: 30, // Ajout d'un padding horizontal par défaut
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
        ),
      ),
    );
  }
}