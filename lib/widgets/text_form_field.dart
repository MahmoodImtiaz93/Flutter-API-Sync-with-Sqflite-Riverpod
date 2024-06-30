import 'package:flutter/material.dart';

Widget buildTextFormField({
  required TextEditingController controller,
  required String labelText,
  required TextInputType keyboardType,
  required String? Function(String?) validator,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      border: const OutlineInputBorder(),
    ),
    keyboardType: keyboardType,
    validator: validator,
  );
}
