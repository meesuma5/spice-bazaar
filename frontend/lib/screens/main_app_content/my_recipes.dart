// Only the content portion of MyRecipesScreen - no Scaffold/AppBar
import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:spice_bazaar/models/users.dart';
import 'package:spice_bazaar/widgets/custom_button.dart';
import 'package:spice_bazaar/widgets/recipe_card.dart';
import 'package:uicons/uicons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uicons_updated/uicons.dart';

class MyRecipesContent extends StatefulWidget {
  final User user; // User object to fetch recipes of
  final Function({Recipe? recipeToEdit})
      showAddRecipe; // Function to show add recipe screen
  final Function(Recipe) onRecipeSelected;
  const MyRecipesContent({
    super.key,
    required this.showAddRecipe,
    required this.user,
    required this.onRecipeSelected,
  });

  @override
  State<MyRecipesContent> createState() => _MyRecipesContentState();
}

class _MyRecipesContentState extends State<MyRecipesContent> {
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
      print('Auth Token: ${widget.user.accessToken}'); // Debugging line
      final response =
          await http.get(Uri.parse('$baseUrl/api/recipes/uploaded/'), headers: {
        'Authorization': 'Bearer ${widget.user.accessToken}',
      });

      // Check if response is valid before proceeding
      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);

        if (decodedResponse is List) {
          setState(() {
            userRecipes = decodedResponse
                .map((recipeJson) => Recipe.fromJson(recipeJson))
                .toList();
            isLoading = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        print(response.body); // Log the response body for debugging
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch recipes: $e';
        isLoading = false;
      });
      print('Error fetching recipes: $e'); // Add detailed logging
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
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
                                                  fontWeight: FontWeight.bold)),
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
                                          widget
                                              .showAddRecipe(); // Call the passed function
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
                                onTap: widget.onRecipeSelected,
                                recipe: userRecipes[index - 1],
                                onEdit: () =>
                                    _editRecipe(userRecipes[index - 1]),
                                onDelete: () => _deleteRecipe(
                                    userRecipes[index - 1].recipeId),
                              ),
                            );
                    },
                  );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(UIcons.regularRounded.room_service,
                size: 80, color: Colors.grey[400]),
            // const SizedBox(height: 8),
            Text(
              'No recipes yet',
              style: poppins(
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            // const SizedBox(height: 5),
            Text('Add your first recipe to get started',
                style: poppins(
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                )),
            const SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: CustomButton(
                text: 'Add Recipe',
                onPressed: () {
                  widget.showAddRecipe();
                },
                icon: const Icon(UiconsRegular.add),
              ),
            ),

            // ElevatedButton.icon(
            //   onPressed: () {
            //     widget
            //         .showAddRecipe(); // Call the passed function for empty state button too
            //   },
            //   icon: const Icon(Icons.add),
            //   label: Text('Add Recipe', style: poppins()),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: mainPurple,
            //     foregroundColor: Colors.white,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _editRecipe(Recipe recipe) {
    // Use the passed function to show edit screen
    widget.showAddRecipe(recipeToEdit: recipe);
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
      // For demo, just remove from the list
      setState(() {
        userRecipes.removeWhere((recipe) => recipe.recipeId == id);
      });
    }
  }
}
