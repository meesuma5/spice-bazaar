import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/profile_drawer.dart';
import 'package:spice_bazaar/widgets/bottom_nav_bar.dart';
import 'package:spice_bazaar/widgets/recipe_card.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:uicons/uicons.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<Recipe> recipes = [];
  bool isLoading = true;
  String? errorMessage;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    try {
      // In a real scenario, fetch from API
      // final response = await http.get(Uri.parse('https://your-api-endpoint.com/api/recipes'));

      // Using dummy data for now
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay

      // Dummy response based on API structure from image 2
      final dummyResponse = {
        "recipes": [
          {
            "id": "1",
            "title": "Spicy Thai Green Curry",
            "description":
                "A fragrant and spicy Thai curry with coconut milk and fresh vegetables.",
            "image_url":
                "https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
            "tags": ["Thai", "Spicy", "Curry"],
            "prep_time": 15,
            "cook_time": 30,
            "rating": 4.8,
            "author": "Jamie Oliver"
          },
          {
            "id": "2",
            "title": "Classic Margherita Pizza",
            "description":
                "Simple yet delicious pizza with tomato, mozzarella, and fresh basil.",
            "image_url":
                "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
            "tags": ["Italian", "Pizza", "Vegetarian"],
            "prep_time": 20,
            "cook_time": 15,
            "rating": 4.5,
            "author": "Gordon Ramsay"
          },
          {
            "id": "3",
            "title": "Vegetable Stir Fry",
            "description":
                "Quick and healthy vegetable stir fry with ginger and soy sauce.",
            "image_url":
                "https://images.unsplash.com/photo-1599297915779-0dadbd376d49?q=80&w=3864&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            "tags": ["Asian", "Vegetarian", "Quick"],
            "prep_time": 10,
            "cook_time": 8,
            "rating": 4.2,
            "author": "Nigella Lawson"
          },
          {
            "id": "4",
            "title": "Japanese Chicken Katsu",
            "description":
                "Crispy panko-breaded chicken cutlets served with tonkatsu sauce.",
            "image_url":
                "https://images.unsplash.com/photo-1604909052743-94e838986d24?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
            "tags": ["Japanese"],
            "prep_time": 10,
            "cook_time": 20,
            "rating": 3.9,
            "author": "Sophia Chen",
          },
          {
            "id": "5",
            "title": "Vegetable Biryani",
            "author": "Priya Sharma",
            "tags": ["Indian"],
            "prep_time": 25,
            "cook_time": 45,
            "rating": 4.9,
            "image_url":
                "https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3",
            "description":
                "Fragrant basmati rice cooked with mixed vegetables and aromatic spices."
          }
        ]
      };

      final List<dynamic> recipeList = dummyResponse['recipes'] as List;

      setState(() {
        recipes = recipeList
            .map((recipeJson) => Recipe.fromJson(recipeJson))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch recipes: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const ProfileDrawer(),
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
          child: Text('SpiceBazaar',
              style: poppins(
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87))),
        ),
        leading: IconButton(
          icon: Icon(UIcons.solidRounded.user),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          Icon(UIcons.regularRounded.equality),
          const SizedBox(width: 16),
        ],
        elevation: 1,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: recipes.length + 1,
                        itemBuilder: (context, index) {
                          return index == 0
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
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
                                  child: RecipeCard(recipe: recipes[index - 1]),
                                );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(index: 1),
    );
  }
}
