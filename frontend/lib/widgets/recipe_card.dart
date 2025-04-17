import 'package:flutter/material.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/widgets/favourite_button.dart';
import 'package:uicons_updated/icons/uicons_regular.dart';
import 'package:uicons_updated/uicons.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final Function(Recipe) onTap;
  final Function(Recipe)? onEdit;
  final Function(Recipe)? onDelete;
  final Function(Recipe) onBookmark;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onBookmark,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  @override
  Widget build(BuildContext context) {
    // For demo purposes, use a placeholder image
    String imageUrl =
        widget.recipe.image != null && widget.recipe.image!.isNotEmpty
            ? widget.recipe.image!
            : baseRecipeImageLink;

    // Get cuisine type from the first tag
    String cuisineType = "";
    if (widget.recipe.tags.isNotEmpty) {
      List<String> words = widget.recipe.tags[0].split(' ');
      if (words.length > 1) {
        cuisineType = words.sublist(0, words.length - 1).join(' ');
      } else {
        cuisineType =
            widget.recipe.tags[0]; // If there's only one word, return that
      }
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
              color: Colors.grey,
              width: 3,
              strokeAlign: BorderSide.strokeAlignOutside)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe Image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  baseRecipeImageLink,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.restaurant,
                            size: 64, color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Title
                Text(
                  widget.recipe.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Cuisine and Author
                Text(
                  "$cuisineType cuisine by ${widget.recipe.author}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  widget.recipe.description.length > 200
                      ? '${widget.recipe.description.substring(0, 200)}...'
                      : widget.recipe.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),

                // Recipe Details Row
                Row(
                  children: [
                    // Cook Time
                    Row(
                      children: [
                        Icon(UiconsRegular.time_forward,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          widget.recipe.formattedPrepTime,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Difficulty
                    Row(
                      children: [
                        Icon(UiconsRegular.restaurant,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _getDifficultyLevel(
                              int.parse(widget.recipe.prepTime)),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 16),

                // View Recipe Button and Bookmark
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () => widget.onTap(widget.recipe),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'View Recipe',
                        style: poppins(
                            style: const TextStyle(color: Colors.black87)),
                      ),
                    ),
                    Row(
											mainAxisSize: MainAxisSize.min,
                      children: [
                        FavouriteButton(
                            recipe: widget.recipe,
                            onBookmark: widget.onBookmark,
                            inactiveColor: Colors.grey,
                            size: 24),
                        if (widget.onEdit != null)
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => widget.onEdit!(widget.recipe),
                                icon: const Icon(Icons.edit),
                                tooltip: 'Edit Recipe',
                              ),
															const SizedBox(width: 2),
                              IconButton(
                                onPressed: () =>
                                    widget.onDelete!(widget.recipe),
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                tooltip: 'Delete Recipe',
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to determine difficulty level
  String _getDifficultyLevel(int totalTime) {
    if (totalTime <= 30) {
      return "Easy";
    } else if (totalTime <= 60) {
      return "Medium";
    } else {
      return "Hard";
    }
  }

  // Helper method to convert rating to likes count for display
  String _getLikesCount(double rating) {
    // This is just a simple conversion for demo
    int likes = (rating * 20).round();
    return likes.toString();
  }
}
