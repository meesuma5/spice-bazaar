import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:uicons/uicons.dart';

class BottomNavBar extends StatelessWidget {
  final int index;
  const BottomNavBar({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: index,
        backgroundColor: Colors.white,
        selectedItemColor: mainPurple,
        selectedLabelStyle: poppins(
            style: const TextStyle(
                color: mainPurple, fontSize: 14, fontWeight: FontWeight.bold)),
        unselectedLabelStyle:
            poppins(style: const TextStyle(color: Colors.grey, fontSize: 12)),
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/recipeRR.svg',
              width: 24,
              height: 24,
              color: Colors.grey,
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/recipeSR.svg',
              width: 30,
              height: 30,
              color: mainPurple,
            ),
            label: 'My Recipes',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/recipe-bookRR.svg',
              width: 24,
              height: 24,
              color: Colors.grey,
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/recipe-bookSR.svg',
              width: 30,
              height: 30,
              color: mainPurple,
            ),
            label: 'Explore Station',
          ),
          BottomNavigationBarItem(
            icon: Icon(UIcons.regularStraight.heart),
            activeIcon: Icon(
              UIcons.solidStraight.heart,
              size: 24,
            ),
            label: 'Favourites',
          ),
        ],
      ),
    );
  }
}
