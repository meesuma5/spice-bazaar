import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';

class InputField extends StatelessWidget {
  final String heading;
  final TextEditingController _fieldController;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;

  const InputField({
    super.key,
    required this.heading,
    required TextEditingController fieldController,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines,
  }) : _fieldController = fieldController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: poppins(
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          style: poppins(style: const TextStyle(fontSize: 12)),
          controller: _fieldController,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          obscureText: obscureText,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}
