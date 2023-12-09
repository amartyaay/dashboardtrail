import 'package:flutter/material.dart';

TextStyle responsiveTextStyle(BuildContext context) {
  return TextStyle(
    fontSize:
        MediaQuery.of(context).size.width < 512 ? MediaQuery.of(context).size.width / 30 : null,
  );
}
