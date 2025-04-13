import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final Icon? icon;
  final double? vPad, hPad;
  final Color? color;
  final TextStyle? textStyle;
  final TextAlign? textAlign;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.icon,
    this.hPad,
    this.vPad,
    this.color,
    this.textStyle,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0.25,
        backgroundColor: isOutlined ? Colors.white : mainPurple,
        foregroundColor: isOutlined ? mainPurple : Colors.white,
        side: isOutlined
            ? BorderSide(color: (color != null) ? color! : borderGray)
            : null,
        padding: EdgeInsets.symmetric(
            horizontal: hPad != null ? hPad! : 48,
            vertical: vPad != null ? vPad! : 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: icon!,
            ),
          Text(
            text,
            textAlign: textAlign,
            style: textStyle ??
                poppins(
                  style: TextStyle(
                    color: isOutlined ? Colors.black87 : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
