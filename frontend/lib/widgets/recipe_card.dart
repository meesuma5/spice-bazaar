import 'package:flutter/material.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:spice_bazaar/constants.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    // For demo purposes, use a placeholder image
    String imageUrl = recipe.imageUrl;

    // Get cuisine type from the first tag
    String cuisineType = recipe.tags.isNotEmpty ? recipe.tags[0] : "";

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
                  recipe.description,
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
                        Icon(Icons.access_time,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          "${recipe.totalTime} min",
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
                        Icon(Icons.restaurant,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _getDifficultyLevel(recipe.totalTime),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Rating / Likes
                    Row(
                      children: [
                        Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _getLikesCount(recipe.rating),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // View Recipe Button and Bookmark
                Row(
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
