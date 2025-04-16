// discover_screen.dart - Renamed to MainAppScreen to reflect its new role
import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/profile_drawer.dart';
import 'package:spice_bazaar/models/users.dart';
import 'package:spice_bazaar/screens/main_app_content/add_recipe.dart';
import 'package:spice_bazaar/screens/main_app_content/my_recipes.dart' show MyRecipesContent, MyRecipesContentState;
import 'package:spice_bazaar/screens/main_app_content/discover.dart' show DiscoverContent, DiscoverContentState;
import 'package:spice_bazaar/screens/main_app_content/view_recipe.dart';
import 'package:spice_bazaar/widgets/bottom_nav_bar.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uicons/uicons.dart';

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
  int _currentIndex = 1; // Start with My Recipes (index 0)
  late User _user;

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

  void _refreshAllData() {
    // Refresh My Recipes content
    if (_myRecipesKey.currentState != null) {
      _myRecipesKey.currentState!.fetchUserRecipes();
    }

    // Refresh Discover content
    if (_discoverKey.currentState != null) {
      _discoverKey.currentState!.fetchRecipes();
    }
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

  void editRecipe(Recipe recipe) {
    print("editing recipe: ${recipe.title}");
    setState(() {
      _showingAddRecipe = true;
      _recipeToEdit = recipe;
      _showingRecipeDetail = false;
    });
  }

  void deleteRecipe(Recipe recipe) {
    // Show confirmation dialog
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
    ).then((confirmed) {
      if (confirmed == true) {
        http.delete(
            Uri.parse('$baseUrl/api/recipes/delete/${recipe.recipeId}/'),
            headers: {
              'Authorization': 'Bearer ${_user.accessToken}',
            });
        setState(() {
          // Remove the recipe from the list

          _showingRecipeDetail = false;
          _showingAddRecipe = false;
          _selectedRecipe = null;
          _recipeToEdit = null;
        });
        _refreshAllData();
      }
    });
  }

  void showProfileDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void hideProfileDrawer() {
    _scaffoldKey.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: ProfileDrawer(user: _user),
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
                icon: Icon(UIcons.solidRounded.user),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
        actions: [
          Icon(UIcons.regularRounded.equality),
          const SizedBox(width: 16),
        ],
        elevation: 1,
      ),
      body: _showingAddRecipe
          ? AddRecipeContent(

              user: _user,
              recipeToEdit: _recipeToEdit,
               back: () => hideAddRecipe(),
              onRecipeAdded: () => hideAddRecipe(recipeAdded: true), // Show Add Recipe when flag is set
					): _showingRecipeDetail
              ? RecipeDetailContent(
                  user: _user,
                  recipe: _selectedRecipe!,
                  onBack: hideRecipeDetail,
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
                      deleteRecipe: deleteRecipe,
                      user: _user,
                    ),
                    DiscoverContent(
											key: _discoverKey,
                      user: _user,
                      onRecipeSelected: showRecipeDetail, // Add this callback
                    ),
                    Container(), // Placeholder for third tab
                  ],
                ),
      bottomNavigationBar: BottomNavBar(
        index: (_showingAddRecipe || _showingRecipeDetail) ? -1 : _currentIndex,
        onTap: _onNavItemTapped,
        onAddRecipe: showAddRecipe,
      ),
    );
  }
}
