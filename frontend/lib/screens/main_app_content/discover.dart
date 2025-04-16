// DiscoverContent - just the content portion of your Discover screen

import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:spice_bazaar/models/users.dart';
import 'package:spice_bazaar/widgets/recipe_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DiscoverContent extends StatefulWidget {
  final Function(Recipe) onRecipeSelected;
  final User user; // User object to fetch recipes of

  const DiscoverContent({
    super.key,
    required this.onRecipeSelected,
    required this.user,
  });

  @override
  State<DiscoverContent> createState() => DiscoverContentState();
}

class DiscoverContentState extends State<DiscoverContent> {
  List<Recipe> recipes = [];
  bool isLoading = true;
  String? errorMessage;
  List<dynamic>? recipeList;

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  void fetchRecipes() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/recipes/catalog/'), headers: {
        'Authorization': 'Bearer ${widget.user.accessToken}',
      });

      // Check if response is valid before proceeding
      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);

        if (decodedResponse is List) {
          setState(() {
            recipes = decodedResponse
                .map((recipeJson) => Recipe.fromJson(recipeJson))
                .toList();
            isLoading = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
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
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  return index == 0
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Discover Recipes',
                                style: poppins(
                                    style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Explore our collection of delicious recipes from around the world.',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: RecipeCard(
                              key: ValueKey(recipes[index - 1].recipeId),
                              recipe: recipes[index - 1],
                              onTap: widget.onRecipeSelected),
                        );
                },
              );
  }
}
