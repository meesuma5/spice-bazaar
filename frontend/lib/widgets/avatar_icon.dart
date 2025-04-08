import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';

class AvatarIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const AvatarIcon({
    super.key,
    required this.icon,
    this.size = 40.0,
    this.iconSize = 20.0,
    this.backgroundColor = mainPurple, // Main purple color
    this.iconColor = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
