import 'package:flutter/material.dart';

TextStyle responsiveTextStyle(BuildContext context) {
  // double height = MediaQuery.of(context).size.height;
  // double width = MediaQuery.of(context).size.width;
  return TextStyle(
    fontSize:
        MediaQuery.of(context).size.width < 512 ? MediaQuery.of(context).size.width / 30 : null,
  );
}
