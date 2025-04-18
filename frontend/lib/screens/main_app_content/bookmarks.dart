import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:spice_bazaar/models/users.dart';
import 'package:spice_bazaar/widgets/recipe_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uicons_updated/icons/uicons_regular.dart';

class FavouritesContent extends StatefulWidget {
  final Function(Recipe) onRecipeSelected;
  final User user; // User object to fetch recipes of
  final Function(Recipe) onBookmark;

  const FavouritesContent({
    super.key,
    required this.onRecipeSelected,
    required this.user,
    required this.onBookmark,
  });

  @override
  State<FavouritesContent> createState() => FavouritesContentState();
}

class FavouritesContentState extends State<FavouritesContent> {
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
      final response = await http
          .get(Uri.parse('$baseUrl/api/recipes/bookmarks/'), headers: {
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
            ? Center(
                child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage!,
                  style: poppins(
                      style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  )),
                ),
              ))
            : (recipes.isNotEmpty)
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recipes.length + 1,
                    itemBuilder: (context, index) {
                      return index == 0
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Favourites',
                                    style: poppins(
                                        style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Revisit recipes you love.',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: RecipeCard(
                                  onBookmark: widget.onBookmark,
                                  key: ValueKey(recipes[index - 1].recipeId),
                                  recipe: recipes[index - 1],
                                  onTap: widget.onRecipeSelected),
                            );
                    },
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Icon(
                            UiconsRegular.user_chef,
                            color: mainPurple,
                            size: 54,
                          ),
                          Text(
                            'Hola Chef! Heart some recipes to see them here.',
                            style: poppins(
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
  }
}
