import 'package:flutter/material.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:uicons_updated/icons/uicons_regular.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final Function(Recipe) onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // For demo purposes, use a placeholder image
    String imageUrl = recipe.image ?? baseRecipeImageLink;

    // Get cuisine type from the first tag
    String cuisineType = "";
    if (recipe.tags.isNotEmpty) {
      List<String> words = recipe.tags[0].split(' ');
      if (words.length > 1) {
        cuisineType = words.sublist(0, words.length - 1).join(' ');
      } else {
        cuisineType = recipe.tags[0]; // If there's only one word, return that
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
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.restaurant, size: 64, color: Colors.grey),
                  ),
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
                  recipe.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Cuisine and Author
                Text(
                  "$cuisineType cuisine by ${recipe.author}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  recipe.description.length > 200
                      ? '${recipe.description.substring(0, 200)}...'
                      : recipe.description,
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
                          recipe.formattedPrepTime,
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
                          _getDifficultyLevel(int.parse(recipe.prepTime)),
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
                      onPressed: () => onTap(recipe),
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
                    IconButton(
                      icon: const Icon(Icons.bookmark_border),
                      onPressed: () {
                        // Toggle bookmark
                      },
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

// Extended RecipeCard with edit and delete options
class UserRecipeCard extends RecipeCard {
  final Function() onEdit;
  final Function() onDelete;

  const UserRecipeCard({
    required super.recipe,
    required this.onEdit,
    required this.onDelete,
    required super.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: // In your RecipeCard widget
                Image.network(
              recipe.image ?? baseRecipeImageLink,
              // Or use a conditional:
              // recipe.image != null ? recipe.image! : AssetImage('assets/placeholder.jpg'),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
                );
              },
            ),
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${recipe.tags.isNotEmpty ? recipe.tags.first : "Other"} cuisine',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(recipe.description),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 20),
                    const SizedBox(width: 4),
                    Text(
                        '${int.parse(recipe.prepTime) + int.parse(recipe.cookTime ?? '0')} min'),
                  ],
                ),
              ],
            ),
          ),

          // Buttons Section
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Navigate to recipe detail screen
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'View Recipe',
                    style:
                        poppins(style: const TextStyle(color: Colors.black87)),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit Recipe',
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Delete Recipe',
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
}
