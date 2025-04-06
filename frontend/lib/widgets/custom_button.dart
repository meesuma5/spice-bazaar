import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0.25,
        backgroundColor: isOutlined ? Colors.white : mainPurple,
        foregroundColor: isOutlined ? mainPurple : Colors.white,
        side: isOutlined ? const BorderSide(color: borderGray) : null,
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: poppins(
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: isOutlined ? Colors.black87 : Colors.white,
          ),
        ),
      ),
    );
  }
}
