import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final bool? obscurText;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  const CustomTextfield(
      {super.key,
      this.obscurText,
      required this.hintText,
      required this.controller,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType ?? TextInputType.text,
      obscureText: obscurText ?? false,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      controller: controller,
    );
  }
}
