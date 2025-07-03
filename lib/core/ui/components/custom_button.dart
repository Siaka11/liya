import 'package:flutter/material.dart';

import '../theme/theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double borderRadius;
  final VoidCallback? onPressedButton;
  final Color? bgColor;
  final double fontSize;
  final double paddingVertical;
  final double? width;
  final double paddingHorizontal;

  const CustomButton({
    super.key,
    required this.text,
    required this.borderRadius,
    this.onPressedButton,
    this.bgColor,
    required this.fontSize,
    required this.paddingVertical,
    this.width,
    this.paddingHorizontal = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressedButton,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor ?? UIColors.defaultColor,
          padding: EdgeInsets.symmetric(
            vertical: paddingVertical,
            horizontal: paddingHorizontal,
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
      ),
    );
  }
}
