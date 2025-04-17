import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:uicons_updated/icons/uicons_regular.dart';
import 'package:uicons_updated/icons/uicons_solid.dart';

class FavouriteButton extends StatefulWidget {
  final Recipe recipe;
  final Color activeColor;
  final Color inactiveColor;
  final Function(Recipe recipe) onBookmark;
  final double size;

  const FavouriteButton(
      {super.key,
      required this.recipe,
      this.activeColor = mainPurple, // Default to mainPurple
      this.inactiveColor = Colors.white,
      required this.onBookmark,
      this.size = 30});

  @override
  State<FavouriteButton> createState() => _FavouriteButtonState();
}

class _FavouriteButtonState extends State<FavouriteButton> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: IconButton(
        key: ValueKey<bool>(widget.recipe.isBookmarked),
        icon: Icon(
          widget.recipe.isBookmarked ? UiconsSolid.heart : UiconsRegular.heart,
          color: widget.recipe.isBookmarked
              ? widget.activeColor
              : widget.inactiveColor,
          size: widget.size,
        ),
        onPressed: () {
          setState(() {
            widget.onBookmark(widget.recipe);
          });
        },
      ),
    );
  }
}
