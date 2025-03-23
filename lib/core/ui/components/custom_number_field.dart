
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerNumberField extends ConsumerWidget{
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String prefixText;
  final double paddingLeft;
  final double fontSize;

  const CustomerNumberField({
    super.key,
    required this.controller,
    required this.keyboardType,
    this.prefixText = "",
    required this.fontSize,
    this.paddingLeft = 12
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