// Updated bottom_nav_bar.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:uicons/uicons.dart';

class BottomNavBar extends StatelessWidget {
  final int index;
  final Function(int) onTap;
  final VoidCallback onAddRecipe; // New callback for Add Recipe button

  const BottomNavBar({
    super.key,
    required this.index,
    required this.onTap,
    required this.onAddRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: const Border.symmetric(
            horizontal: BorderSide(width: 0.5, color: borderGray),
            vertical: BorderSide.none),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
							child: _buildNavItem(
									itemIndex: 0,
									label: 'My Creations',
									isAsset: true,
									imagePath: "assets/icons/recipeRR.svg"),
						),
            Expanded(
							child: _buildNavItem(
									itemIndex: 1,
									icon: UIcons.regularRounded.drafting_compass,
									label: 'Chef\'s Book',
									isAsset: true,
									imagePath: "assets/icons/recipe-bookRR.svg"),
						),
            Expanded(
							child: _buildNavItem(
									itemIndex: 2,
									icon: UIcons.regularRounded.heart,
									label: 'Favorites'),
						),
            // _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      {required int itemIndex,
      IconData? icon,
      required String label,
      bool isAsset = false,
      String? imagePath}) {
    final isActive = index == itemIndex;
    return InkWell(
      onTap: () => onTap(itemIndex),
      child: Column(
      	mainAxisSize: MainAxisSize.min,
      	children: [
      		// Use Icon widget for non-asset icons
      		if (isAsset && imagePath != null)
      			// Use SvgPicture widget for SVG assets
      			SvgPicture.asset(
      				imagePath,
      				height: 27,
      				width: 27,
      				color: isActive ? mainPurple : Colors.grey,
      			)
      		else
      			// Use Icon widget for non-asset icons
      			Icon(
      				icon,
      				size: 27,
      				color: isActive ? mainPurple : Colors.grey,
      			),
      		const SizedBox(height: 4),
      		Text(label,
      				style: poppins(
      					style: TextStyle(
      						color: isActive ? mainPurple : Colors.grey,
      						fontSize:  12,
      										fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
      					),
      				)),
      	],
      ),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: onAddRecipe, // Use the special callback for Add Recipe
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              UIcons.regularRounded.add,
              color: Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              'Add Recipe',
              style: poppins(
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
