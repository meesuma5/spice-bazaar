import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:spice_bazaar/widgets/custom_button.dart';
import 'package:spice_bazaar/widgets/recipe_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uicons/uicons.dart';

class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  List<Recipe> userRecipes = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserRecipes();
  }

  Future<void> _fetchUserRecipes() async {
    try {
      // In a real scenario, fetch from API with auth token
      // final token = await getAuthToken();
      // final response = await http.get(
      //   Uri.parse('https://api.spicebazaar.com/api/user/recipes'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );

      // Using dummy data for now
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay

      // Dummy response
      final dummyResponse = {
        "user_recipes": [
          {
            "id": "101",
            "title": "Homemade Pasta Carbonara",
            "description":
                "Creamy pasta dish with pancetta, eggs, and parmesan cheese.",
            "image_url":
                "https://images.unsplash.com/photo-1612874742237-6526221588e3?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
            "tags": ["Italian", "Pasta", "Creamy"],
            "prep_time": 15,
            "cook_time": 20,
            "rating": 4.7,
            "author": "You"
          },
          {
            "id": "102",
            "title": "Spicy Chicken Tacos",
            "description":
                "Tender spiced chicken in soft corn tortillas with homemade salsa and guacamole.",
            "image_url":
                "https://images.unsplash.com/photo-1599974579688-8dbdd335c77f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
            "tags": ["Mexican", "Spicy", "Chicken"],
            "prep_time": 20,
            "cook_time": 15,
            "rating": 4.6,
            "author": "You"
          },
          {
            "id": "103",
            "title": "Chocolate Chip Cookies",
            "description":
                "Classic homemade chocolate chip cookies with a soft center and crispy edges.",
            "image_url":
                "https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
            "tags": ["Dessert", "Baking", "Sweet"],
            "prep_time": 15,
            "cook_time": 10,
            "rating": 4.9,
            "author": "You"
          }
        ]
      };

      final List<dynamic> recipeList = dummyResponse['user_recipes'] as List;

      setState(() {
        userRecipes = recipeList
            .map((recipeJson) => Recipe.fromJson(recipeJson))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch your recipes: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : userRecipes.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: userRecipes.length + 1,
                      itemBuilder: (context, index) {
                        return index == 0
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'My Recipes',
                                            style: poppins(
                                                style: const TextStyle(
                                                    fontSize: 28,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                              'Manage and explore your culinary creations',
                                              style: poppins(
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[600]),
                                              )),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomButton(
                                          text: "Add Recipe",
                                          hPad: 4,
                                          textAlign: TextAlign.center,
                                          textStyle: poppins(
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                context, '/addrecipe');
                                          },
                                          icon: Icon(
                                            UIcons.regularRounded.add,
                                            size: 14,
                                          ),
                                          isOutlined: false),
                                    ),
                                  ],
                                ))
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: UserRecipeCard(
                                  recipe: userRecipes[index - 1],
                                  onEdit: () => _editRecipe(userRecipes[index]),
                                  onDelete: () =>
                                      _deleteRecipe(userRecipes[index].id),
                                ),
                              );
                      },
                    ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(UIcons.regularRounded.room_service,
              size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No recipes yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first recipe to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to add recipe screen
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Recipe'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[300],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _editRecipe(Recipe recipe) {
    // Navigate to edit recipe screen
    // Navigator.push(context, MaterialPageRoute(builder: (context) => EditRecipeScreen(recipe: recipe)));
  }

  Future<void> _deleteRecipe(String id) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text('Are you sure you want to delete this recipe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // In a real app, call the API to delete the recipe
      // final response = await http.delete(
      //   Uri.parse('https://api.spicebazaar.com/api/recipes/$id'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );

      // For demo, just remove from the list
      setState(() {
        userRecipes.removeWhere((recipe) => recipe.id == id);
      });
    }
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
            child: Image.network(
              recipe.imageUrl,
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
                    Text('${recipe.prepTime + recipe.cookTime} min'),
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
