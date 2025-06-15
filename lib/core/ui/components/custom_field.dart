
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomField extends ConsumerWidget{
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String prefixText;
  final double paddingLeft;
  final double fontSize;
  final InputDecoration? decoration;
  final String? placeholder;

  const CustomField({
    super.key,
    required this.controller,
    required this.keyboardType,
    this.prefixText = "",
    required this.fontSize,
    this.paddingLeft = 12,
    this.decoration,
    this.placeholder,

  });

  @override
  Widget build(BuildContext context, WidgetRef ref){
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          hintText: placeholder,
            focusColor: Colors.red,
            prefixText: prefixText,
            prefixStyle: TextStyle(fontSize: fontSize),
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(left: paddingLeft)
        ),
      ),
    );
  }
}