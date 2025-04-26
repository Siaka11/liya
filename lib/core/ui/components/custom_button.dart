import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget{
  final String text;
  final VoidCallback? onPressedButton;
  final Color bgColor;
  final double fontSize;
  final double paddingVertical;
  final double borderRaduis;


  const CustomButton({
      super.key,
      required this.text,
      required this.onPressedButton,
      this.bgColor = Colors.black,
      this.fontSize = 16,
      this.paddingVertical = 16,
      required this.borderRaduis,
});

  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: onPressedButton,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: paddingVertical),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRaduis)
            )
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize, color: bgColor),
          )
      ),
    );
  }
}