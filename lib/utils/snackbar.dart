import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, {bool isError = true}){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    ),
  );
}