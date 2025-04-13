// discover_screen.dart - Renamed to MainAppScreen to reflect its new role
import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/profile_drawer.dart';
import 'package:spice_bazaar/models/users.dart';
import 'package:spice_bazaar/screens/main_app_content/add_recipe.dart';
import 'package:spice_bazaar/screens/main_app_content/discover.dart';
import 'package:spice_bazaar/screens/main_app_content/my_recipes.dart';
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
  int _currentIndex = 1; // Start with My Recipes (index 0)
  late User _user;

  // Track if AddRecipe is currently shown
  bool _showingAddRecipe = false;
	// Track if a Recipe is currently being seen
  bool _showingRecipe = false; 

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

  void _onNavItemTapped(int index) {
    setState(() {
      print(index);
      _currentIndex = index;
      _showingAddRecipe = false; // Reset add recipe flag when nav button tapped
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
            _showingAddRecipe
                ? _recipeToEdit != null
                    ? 'Edit Recipe'
                    : 'Add Recipe'
                : 'SpiceBazaar',
            style: poppins(
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
        ),
        leading: _showingAddRecipe
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    print(_currentIndex);
                    _showingAddRecipe = false;
                    _recipeToEdit = null;
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
          ? const AddRecipeContent() // Show Add Recipe when flag is set
          : IndexedStack(
              index: _currentIndex,
              children: [
                MyRecipesContent(
                  showAddRecipe: showAddRecipe,
                  user: _user, // Pass the method down
                ), // Index 0 - My Recipes Content
                _showingRecipe ? DiscoverContent() :, // Index 1 - Discover Content
                Container(), // Index 2 - Placeholder for third tab if needed
              ],
            ),
      bottomNavigationBar: BottomNavBar(
        index: _showingAddRecipe
            ? -1
            : _currentIndex, // Pass -1 when showing add recipe
        onTap: _onNavItemTapped,
        onAddRecipe: showAddRecipe, // Add new callback for Add Recipe button
      ),
    );
  }
}
