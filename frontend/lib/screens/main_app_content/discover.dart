// DiscoverContent - just the content portion of your Discover screen

import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:spice_bazaar/models/recipe_filters.dart';
import 'package:spice_bazaar/models/users.dart';
import 'package:spice_bazaar/widgets/recipe_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uicons_updated/uicons.dart';

class DiscoverContent extends StatefulWidget {
  final Function(Recipe) onRecipeSelected;
  final User user; // User object to fetch recipes of
  final Function(Recipe) onBookmark;

  const DiscoverContent({
    super.key,
    required this.onRecipeSelected,
    required this.user,
    required this.onBookmark,
  });

  @override
  State<DiscoverContent> createState() => DiscoverContentState();
}

class DiscoverContentState extends State<DiscoverContent> {
  final RecipeFilters _filters = RecipeFilters();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _filterScaffoldKey =
      GlobalKey<ScaffoldState>();

  List<Recipe> recipes = [];
  List<Recipe> filteredRecipes = [];
  bool isLoading = true;
  String? errorMessage;
  List<dynamic>? recipeList;

  // Get all unique tags from recipes
  List<String> getAllTags() {
    Set<String> tags = {};
    for (var recipe in recipes) {
      tags.addAll(recipe.tags);
    }
    return tags.toList()..sort();
  }

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

  void updateFilters(RecipeFilters newFilters) {
    setState(() {
      _filters.searchQuery = newFilters.searchQuery;
      _filters.selectedTags = List.from(newFilters.selectedTags);
      _filters.maxPrepTime = newFilters.maxPrepTime;
      _filters.maxCookTime = newFilters.maxCookTime;
      _filters.sortBy = newFilters.sortBy;
    });
  }

  // Add this helper method to DiscoverContentState
  String getSortOptionName(SortOption option) {
    switch (option) {
      case SortOption.none:
        return 'None';
      case SortOption.titleAsc:
        return 'Title A-Z';
      case SortOption.titleDesc:
        return 'Title Z-A';
      case SortOption.ratingDesc:
        return 'Highest Rating';
      case SortOption.ratingAsc:
        return 'Lowest Rating';
      case SortOption.prepTimeAsc:
        return 'Quickest Prep';
      case SortOption.prepTimeDesc:
        return 'Longest Prep';
      case SortOption.dateDesc:
        return 'Newest First';
      case SortOption.dateAsc:
        return 'Oldest First';
      default:
        return 'Unknown';
    }
  }

  void applyFilters() {
    setState(() {
      filteredRecipes = recipes.where((recipe) {
        // Apply search filter
        if (_filters.searchQuery != null && _filters.searchQuery!.isNotEmpty) {
          final query = _filters.searchQuery!.toLowerCase();
          final matchesTitle = recipe.title.toLowerCase().contains(query);
          final matchesDescription =
              recipe.description.toLowerCase().contains(query);
          if (!matchesTitle && !matchesDescription) {
            return false;
          }
        }

        // Apply tag filter
        if (_filters.selectedTags.isNotEmpty) {
          // Check if the recipe has any of the selected tags
          bool hasMatchingTag = false;
          for (final selectedTag in _filters.selectedTags) {
            // Make sure we're doing case-insensitive comparison
            for (final recipeTag in recipe.tags) {
              if (recipeTag.toLowerCase() == selectedTag.toLowerCase()) {
                hasMatchingTag = true;
                break;
              }
            }
            if (hasMatchingTag) break; // Exit the loop if we found a match
          }

          if (!hasMatchingTag) {
            return false;
          }
        }

        // Apply prep time filter
        if (_filters.maxPrepTime != null) {
          final prepTimeMinutes =
              int.tryParse(recipe.getPrepTimeInMinutes()) ?? 0;
          if (prepTimeMinutes > _filters.maxPrepTime!) {
            return false;
          }
        }

        // Apply cook time filter
        if (_filters.maxCookTime != null) {
          final cookTimeMinutes =
              int.tryParse(recipe.getCookTimeInMinutes()) ?? 0;
          if (cookTimeMinutes > _filters.maxCookTime!) {
            return false;
          }
        }
        return true;
      }).toList();
      print("Filtered recipes: ${filteredRecipes.length}");
      // Apply sorting
      print("Sort option: ${_filters.sortBy}");
      if (_filters.sortBy != SortOption.none) {
        filteredRecipes.sort(
          (a, b) {
            switch (_filters.sortBy) {
              case SortOption.titleAsc:
                return a.title.toLowerCase().compareTo(b.title.toLowerCase());
              case SortOption.titleDesc:
                return b.title.toLowerCase().compareTo(a.title.toLowerCase());
              case SortOption.ratingDesc:
                // Assuming recipes have a rating field; adjust if needed
                return (b.rating).compareTo(a.rating);
              case SortOption.ratingAsc:
                return (a.rating).compareTo(b.rating);
              case SortOption.prepTimeAsc:
                int aPrepTime = int.tryParse(a.getPrepTimeInMinutes()) ?? 0;
                int bPrepTime = int.tryParse(b.getPrepTimeInMinutes()) ?? 0;
                return aPrepTime.compareTo(bPrepTime);
              case SortOption.prepTimeDesc:
                int aPrepTime = int.tryParse(a.getPrepTimeInMinutes()) ?? 0;
                int bPrepTime = int.tryParse(b.getPrepTimeInMinutes()) ?? 0;
                return bPrepTime.compareTo(aPrepTime);
              case SortOption.dateDesc:
                // Assuming recipes have a date field; adjust based on your model
                return b.uploadDate.compareTo(a.uploadDate);
              case SortOption.dateAsc:
                return a.uploadDate.compareTo(b.uploadDate);
              default:
                return 0;
            }
          },
        );
      }
    });
  }

  void _openFilterDrawer() {
    Scaffold.of(context).openEndDrawer();
  }

  void _onSearch(String query) {
    setState(() {
      _filters.searchQuery = query.isNotEmpty ? query : null;
      applyFilters();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filters.searchQuery = null;
      applyFilters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : errorMessage != null
            ? Center(child: Text(errorMessage!))
            : Column(
                children: [
                  // Search field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      style: poppins(),
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search recipes...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(UiconsRegular.cross, size: 18),
                                onPressed: _clearSearch,
                              )
                            : null,
                      ),
                      onChanged: _onSearch,
                    ),
                  ),

                  // Active filters display
                  if (_filters.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (_filters.sortBy != SortOption.none)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Chip(
                                        label: Text(
                                          'Sort: ${getSortOptionName(_filters.sortBy)}',
                                          style: poppins(),
                                        ),
                                        onDeleted: () {
                                          setState(() {
                                            _filters.sortBy = SortOption.none;
                                            applyFilters();
                                          });
                                        },
                                      ),
                                    ),
                                  ..._filters.selectedTags.map((tag) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Chip(
                                          label: Text(tag, style: poppins()),
                                          onDeleted: () {
                                            setState(() {
                                              _filters.selectedTags.remove(tag);
                                              applyFilters();
                                            });
                                          },
                                        ),
                                      )),
                                  if (_filters.maxPrepTime != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Chip(
                                        label: Text(
                                            'Prep: ≤${_filters.maxPrepTime}min',
                                            style: poppins()),
                                        onDeleted: () {
                                          setState(() {
                                            _filters.maxPrepTime = null;
                                            applyFilters();
                                          });
                                        },
                                      ),
                                    ),
                                  if (_filters.maxCookTime != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Chip(
                                        label: Text(
                                            'Cook: ≤${_filters.maxCookTime}min',
                                            style: poppins()),
                                        onDeleted: () {
                                          setState(() {
                                            _filters.maxCookTime = null;
                                            applyFilters();
                                          });
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // List of recipes
                  if (_filters.isActive)
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredRecipes.length + 1,
                        itemBuilder: (context, index) {
                          return index == 0
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 4),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Discover Recipes',
                                            style: poppins(
                                                style: const TextStyle(
                                                    fontSize: 28,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          // Filter button
                                          Badge(
                                            isLabelVisible: _filters
                                                    .selectedTags.isNotEmpty ||
                                                _filters.maxPrepTime != null ||
                                                _filters.maxCookTime != null,
                                            child: IconButton(
                                              icon:
                                                  const Icon(Icons.filter_list),
                                              onPressed: _openFilterDrawer,
                                              tooltip: 'Filter recipes',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Explore our collection of delicious recipes from around the world.',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 8),
                                      if (filteredRecipes.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 40),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                const Icon(Icons.search_off,
                                                    size: 64,
                                                    color: Colors.grey),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'No recipes match your filters',
                                                  style: poppins(
                                                      style: const TextStyle(
                                                          fontSize: 16)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: RecipeCard(
                                      onBookmark: widget.onBookmark,
                                      key: ValueKey(
                                          filteredRecipes[index - 1].recipeId),
                                      recipe: filteredRecipes[index - 1],
                                      onTap: widget.onRecipeSelected),
                                );
                        },
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: recipes.length + 1,
                        itemBuilder: (context, index) {
                          return index == 0
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 12.0, left: 4, right: 4, top: 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            fontSize: 16,
                                            color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: RecipeCard(
                                      onBookmark: widget.onBookmark,
                                      key:
                                          ValueKey(recipes[index - 1].recipeId),
                                      recipe: recipes[index - 1],
                                      onTap: widget.onRecipeSelected),
                                );
                        },
                      ),
                    ),
                ],
              );
  }
}
