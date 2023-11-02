import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String content, Color backgroundColor) {
  final snackBar = SnackBar(
    content: Text(content),
    backgroundColor: backgroundColor,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
