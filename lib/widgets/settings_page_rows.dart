import 'package:flutter/material.dart';

Widget customRow({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  required String? intialValue,
}) {
  if (intialValue != null) {
    controller.text = intialValue;
  }
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 16.0),
        // Text(
        //   hintText,
        //   style: const TextStyle(fontSize: 16, color: Colors.black),
        // ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
