// discover_screen.dart - Renamed to MainAppScreen to reflect its new role
import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/widgets/profile_drawer.dart';
import 'package:spice_bazaar/widgets/unit_conversion.dart';
import 'package:spice_bazaar/models/users.dart';
import 'package:spice_bazaar/screens/main_app_content/add_recipe.dart';
import 'package:spice_bazaar/screens/main_app_content/bookmarks.dart';
import 'package:spice_bazaar/screens/main_app_content/my_recipes.dart'
    show MyRecipesContent, MyRecipesContentState;
import 'package:spice_bazaar/screens/main_app_content/discover.dart'
    show DiscoverContent, DiscoverContentState;
import 'package:spice_bazaar/screens/main_app_content/view_recipe.dart';
import 'package:spice_bazaar/widgets/bottom_nav_bar.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:http/http.dart' as http;
import 'package:uicons/uicons.dart';
import 'package:spice_bazaar/models/recipe_filters.dart';
import 'package:spice_bazaar/widgets/recipe_filters_drawer.dart';
import 'package:uicons_updated/uicons.dart';

class MainAppScreen extends StatefulWidget {
  final User user;

  const MainAppScreen({
    super.key,
    required this.user,
  });

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<MyRecipesContentState> _myRecipesKey =
      GlobalKey<MyRecipesContentState>();
  final GlobalKey<DiscoverContentState> _discoverKey =
      GlobalKey<DiscoverContentState>();
  final GlobalKey<FavouritesContentState> _favouritesKey =
      GlobalKey<FavouritesContentState>();
  int _currentIndex = 1; // Start with My Recipes (index 0)
  late User _user;
  final RecipeFilters _recipeFilters = RecipeFilters();
  bool showFilters = false;
  // List of all tags for filtering
  // This should be populated with actual data from your backend or a predefined list
  // For now, it's an empty list
  List<String> _allTags = [];

  // Track if AddRecipe is currently shown
  bool _showingAddRecipe = false;
  // Track if a Recipe is currently being seen
  bool _showingRecipeDetail = false;
  Recipe? _selectedRecipe;

  // For editing a recipe
  Recipe? _recipeToEdit;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void refreshFavourites() {
    if (_favouritesKey.currentState != null) {
      _favouritesKey.currentState!.fetchRecipes();
    }
  }

  void _refreshAllData() {
    // Refresh My Recipes content
    if (_myRecipesKey.currentState != null) {
      _myRecipesKey.currentState!.fetchUserRecipes();
    }

    // Refresh Discover content
    if (_discoverKey.currentState != null) {
      _discoverKey.currentState!.fetchRecipes();
    }
    // Refresh Favourites content
    refreshFavourites();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      print(index);
      _currentIndex = index;
      _showingAddRecipe = false; // Reset add recipe flag when nav button tapped
      _showingRecipeDetail =
          false; // Reset recipe detail flag when nav button tapped
      _recipeToEdit = null; // Clear any recipe being edited
    });
  }

  void showAddRecipe({Recipe? recipeToEdit}) {
    setState(() {
      _showingAddRecipe = true;
      _recipeToEdit =
          recipeToEdit; // Store the recipe to edit (null if adding new)
    });
  }

  void hideAddRecipe({bool recipeAdded = false}) {
    setState(() {
      _showingAddRecipe = false;
      _recipeToEdit = null;

      // If a recipe was added or edited, refresh data
      if (recipeAdded) {
        _refreshAllData();
      }
    });
  }

  void showRecipeDetail(Recipe recipe) {
    print('Showing recipe detail for: ${recipe.title}');
    setState(() {
      _showingRecipeDetail = true;
      _selectedRecipe = recipe;
    });
  }

  void hideRecipeDetail() {
    setState(() {
      _showingRecipeDetail = false;
      _selectedRecipe = null;
    });
  }

  void bookmarkRecipe(Recipe recipe) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/acc/bookmark/'),
      headers: {
        'Authorization': 'Bearer ${_user.accessToken}',
      },
      body: {
        'recipe_id': recipe.recipeId,
      },
    );
    if (resp.statusCode == 201) {
      print('Recipe bookmarked successfully');
      setState(() {
        refreshFavourites();
      });
      ();
    } else {
      print('Failed to bookmark recipe: ${resp.statusCode}');
    }
  }

  void unbookmarkRecipe(Recipe recipe) async {
    final resp = await http.delete(
      Uri.parse('$baseUrl/api/acc/bookmark/${recipe.recipeId}/delete/'),
      headers: {
        'Authorization': 'Bearer ${_user.accessToken}',
      },
    );
    if (resp.statusCode == 200) {
      print('Recipe unbookmarked successfully');
      refreshFavourites();
    } else {
      print('Failed to unbookmark recipe: ${resp.statusCode}');
    }
  }

  // Bookmark
  void onBookmark(Recipe recipe) {
    setState(() {
      recipe.toggleBookmark();
    });
    if (recipe.isBookmarked) {
      bookmarkRecipe(recipe);
    } else {
      unbookmarkRecipe(recipe);
    }
  }

  // Function to edit a recipe
  void editRecipe(Recipe recipe) {
    print("editing recipe: ${recipe.title}");
    setState(() {
      _showingAddRecipe = true;
      _recipeToEdit = recipe;
      _showingRecipeDetail = false;
    });
  }

  void _hardRefresh() {
    // Refresh My Recipes content
    // Force rebuilding by setting the current index again
    setState(() {});

    // Use Future.delayed to ensure the UI updates before we attempt to refresh data
    // This gives Flutter time to dispose of any existing state
    Future.delayed(const Duration(milliseconds: 100), () {
      // Explicitly set to rebuild with fresh data
      setState(() {
        // Reset the current tab to force a complete rebuild
        int currentTab = _currentIndex;
        _currentIndex = -1; // Set to invalid index temporarily

        // Apply after frame to ensure widget tree is updated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _currentIndex = currentTab; // Restore original index
          });
          _refreshAllData(); // Refresh all data
          print('Refreshed all data');
        });
      });
    });
  }

  void deleteRecipe(Recipe recipe) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Recipe', style: poppins()),
        content: Text('Are you sure you want to delete this recipe?',
            style: poppins()),
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
    ).then((confirmed) async {
      if (confirmed == true) {
        try {
          final response = await http.delete(
            Uri.parse('$baseUrl/api/recipes/delete/${recipe.recipeId}/'),
            headers: {
              'Authorization': 'Bearer ${_user.accessToken}',
            },
          );

          if (response.statusCode == 200 || response.statusCode == 204) {
            setState(() {
              _showingRecipeDetail = false;
              _selectedRecipe = null;
            });
            _hardRefresh(); // Refresh the data after deletion
            // Show success notification
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recipe deleted successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Failed to delete recipe: ${response.statusCode}')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    });
  }

  // Function to update the list of tags
  void updateTagsList() {
    if (_discoverKey.currentState != null) {
      setState(() {
        _allTags = _discoverKey.currentState!.getAllTags();
      });
    }
  }

  void showProfileDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void hideProfileDrawer() {
    _scaffoldKey.currentState?.closeDrawer();
  }

  void showUnitConverterDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void hideUnitConverterDrawer() {
    _scaffoldKey.currentState?.closeEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: ProfileDrawer(user: _user),
      endDrawer: (showFilters)
          ? FilterDrawer(
              filters: _recipeFilters,
              availableTags: _allTags,
              onFiltersChanged: (newFilters) {
                setState(() {
                  _recipeFilters.searchQuery = newFilters.searchQuery;
                  _recipeFilters.selectedTags = newFilters.selectedTags;
                  _recipeFilters.maxPrepTime = newFilters.maxPrepTime;
                  _recipeFilters.maxCookTime = newFilters.maxCookTime;
									_recipeFilters.sortBy = newFilters.sortBy;
                });
                if (_discoverKey.currentState != null) {
                  _discoverKey.currentState!.updateFilters(_recipeFilters);
                }
              },
              onApply: () {
                if (_discoverKey.currentState != null) {
                  _discoverKey.currentState!.applyFilters();
                }
              },
            )
          : const UnitConverterDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
                color: Colors.black12,
                width: 0.5,
                strokeAlign: BorderSide.strokeAlignOutside)),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _showingRecipeDetail
                ? _selectedRecipe?.title ?? 'Recipe'
                : _showingAddRecipe
                    ? _recipeToEdit != null
                        ? 'Edit Recipe'
                        : 'Add Recipe'
                    : 'SpiceBazaar',
            style: poppins(
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
        ),
        leading: (_showingAddRecipe || _showingRecipeDetail)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    if (_showingAddRecipe) {
                      _showingAddRecipe = false;
                      _recipeToEdit = null;
                    } else if (_showingRecipeDetail) {
                      _showingRecipeDetail = false;
                      _selectedRecipe = null;
                    }
                  });
                },
              )
            : IconButton(
                icon: const Icon(
                  UiconsSolid.user,
                  size: 24,
                ),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
        actions: [
          if (_currentIndex == 1 && !_showingAddRecipe && !_showingRecipeDetail)
            IconButton(
              icon: const Icon(
                UiconsRegular.filter,
                size: 24,
              ),
              onPressed: () => endDrawerOpener(isFilters: true),
            ),
          IconButton(
            icon: Icon(UIcons.regularRounded.equality, size: 24),
            onPressed: () => endDrawerOpener(),
          ),
          const SizedBox(width: 16),
        ],
        elevation: 1,
      ),
      body: _showingAddRecipe
          ? AddRecipeContent(
              user: _user,
              recipeToEdit: _recipeToEdit,
              back: () => hideAddRecipe(),
              onRecipeAdded: () => hideAddRecipe(
                  recipeAdded: true), // Show Add Recipe when flag is set
            )
          : _showingRecipeDetail
              ? RecipeDetailContent(
                  user: _user,
                  recipe: _selectedRecipe!,
                  onBack: hideRecipeDetail,
                  onBookmark: onBookmark,
                  onEdit: editRecipe,
                  onDelete: deleteRecipe,
                )
              : IndexedStack(
                  index: _currentIndex,
                  children: [
                    MyRecipesContent(
                      key: _myRecipesKey,
                      showAddRecipe: showAddRecipe,
                      onRecipeSelected: showRecipeDetail, // Add this callback
                      onBookmark: onBookmark,
                      deleteRecipe: deleteRecipe,
                      user: _user,
                    ),
                    DiscoverContent(
                      key: _discoverKey,
                      user: _user,
                      onRecipeSelected: showRecipeDetail, // Add this callback
                      onBookmark: onBookmark,
                    ),
                    FavouritesContent(
                      key: _favouritesKey,
                      onRecipeSelected: showRecipeDetail,
                      user: widget.user,
                      onBookmark: onBookmark,
                    ), // Placeholder for third tab
                  ],
                ),
      bottomNavigationBar: BottomNavBar(
        index: (_showingAddRecipe || _showingRecipeDetail) ? -1 : _currentIndex,
        onTap: _onNavItemTapped,
        onAddRecipe: showAddRecipe,
      ),
    );
  }

  void endDrawerOpener({bool isFilters = false}) {
    setState(() {
      showFilters = isFilters;
    });
    if (isFilters) {
      updateTagsList();
    }
    _scaffoldKey.currentState?.openEndDrawer();
  }
}
