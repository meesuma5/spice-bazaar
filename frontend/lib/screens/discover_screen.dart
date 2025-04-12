// discover_screen.dart - Renamed to MainAppScreen to reflect its new role
import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/profile_drawer.dart';
import 'package:spice_bazaar/screens/add_recipe.dart';
import 'package:spice_bazaar/screens/my_recipes.dart';
import 'package:spice_bazaar/widgets/bottom_nav_bar.dart';
import 'package:spice_bazaar/widgets/custom_button.dart';
import 'package:spice_bazaar/widgets/recipe_card.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uicons/uicons.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0; // Start with My Recipes (index 0)
  late PageController _pageController;

  // Track if AddRecipe is currently shown
  bool _showingAddRecipe = false;

  // For editing a recipe
  Recipe? _recipeToEdit;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _showingAddRecipe = false; // Reset add recipe flag when nav button tapped
      _recipeToEdit = null; // Clear any recipe being edited
    });
    _pageController.jumpToPage(index);
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
          : PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                MyRecipesContent(
                  showAddRecipe: showAddRecipe, // Pass the method down
                ), // Index 0 - My Recipes Content
                const DiscoverContent(), // Index 1 - Discover Content
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

// Only the content portion of MyRecipesScreen - no Scaffold/AppBar
class MyRecipesContent extends StatefulWidget {
  final Function({Recipe? recipeToEdit})
      showAddRecipe; // Function to show add recipe screen

  const MyRecipesContent({
    Key? key,
    required this.showAddRecipe,
  }) : super(key: key);

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
      // Using dummy data for now
      await Future.delayed(const Duration(seconds: 1));

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
                                recipe: userRecipes[index - 1],
                                onEdit: () =>
                                    _editRecipe(userRecipes[index - 1]),
                                onDelete: () =>
                                    _deleteRecipe(userRecipes[index - 1].id),
                              ),
                            );
                    },
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
              widget
                  .showAddRecipe(); // Call the passed function for empty state button too
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
        userRecipes.removeWhere((recipe) => recipe.id == id);
      });
    }
  }
}

// DiscoverContent - just the content portion of your Discover screen
class DiscoverContent extends StatefulWidget {
  const DiscoverContent({super.key});

  @override
  State<DiscoverContent> createState() => _DiscoverContentState();
}

class _DiscoverContentState extends State<DiscoverContent> {
  List<Recipe> recipes = [];
  bool isLoading = true;
  String? errorMessage;

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
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : errorMessage != null
            ? Center(child: Text(errorMessage!))
            : ListView.builder(
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
                          child: RecipeCard(recipe: recipes[index - 1]),
                        );
                },
              );
  }
}

class AddRecipeContent extends StatefulWidget {
  final Recipe? recipeToEdit; // Pass recipe to edit (null for new recipe)

  const AddRecipeContent({
    Key? key,
    this.recipeToEdit,
  }) : super(key: key);

  @override
  State<AddRecipeContent> createState() => _AddRecipeContentState();
}

class _AddRecipeContentState extends State<AddRecipeContent> {
  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _prepTimeController;
  late TextEditingController _cookTimeController;
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with values from recipeToEdit if provided
    _titleController =
        TextEditingController(text: widget.recipeToEdit?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.recipeToEdit?.description ?? '');
    _imageUrlController =
        TextEditingController(text: widget.recipeToEdit?.imageUrl ?? '');
    _prepTimeController = TextEditingController(
        text: widget.recipeToEdit?.prepTime != null
            ? widget.recipeToEdit!.prepTime.toString()
            : '');
    _cookTimeController = TextEditingController(
        text: widget.recipeToEdit?.cookTime != null
            ? widget.recipeToEdit!.cookTime.toString()
            : '');

    // Set selected tags if editing
    if (widget.recipeToEdit != null) {
      _selectedTags = List.from(widget.recipeToEdit!.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.recipeToEdit != null ? 'Edit Recipe' : 'Add New Recipe',
            style: poppins(
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),

          // Form fields
          _buildTextField(
            controller: _titleController,
            label: 'Recipe Title',
            hintText: 'Enter the name of your recipe',
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            hintText: 'Describe your recipe',
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _imageUrlController,
            label: 'Image URL',
            hintText: 'Enter URL for recipe image',
          ),
          const SizedBox(height: 16),

          // Row for prep and cook time
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _prepTimeController,
                  label: 'Prep Time (mins)',
                  hintText: 'e.g. 15',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _cookTimeController,
                  label: 'Cook Time (mins)',
                  hintText: 'e.g. 30',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tags section
          Text(
            'Cuisine Tags',
            style: poppins(
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          _buildTagSelector(),

          const SizedBox(height: 32),

          // Save button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: widget.recipeToEdit != null ? "Save Changes" : "Add Recipe",
              textAlign: TextAlign.center,
              textStyle: poppins(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: _saveRecipe,
              isOutlined: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: poppins(style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  Widget _buildTagSelector() {
    // Sample cuisine tags
    final List<String> availableTags = [
      "Italian",
      "Mexican",
      "Asian",
      "Indian",
      "Thai",
      "Japanese",
      "American",
      "French",
      "Mediterranean",
      "Vegetarian",
      "Vegan",
      "Dessert",
      "Breakfast",
      "Lunch",
      "Dinner",
      "Spicy",
      "Quick",
      "Healthy",
      "Comfort Food"
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableTags.map((tag) {
        final isSelected = _selectedTags.contains(tag);

        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedTags.add(tag);
              } else {
                _selectedTags.remove(tag);
              }
            });
          },
          backgroundColor: Colors.white,
          selectedColor: Colors.purple[100],
          checkmarkColor: Colors.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? Colors.purple[300]! : Colors.grey[300]!,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _saveRecipe() {
    // In a real app, you would validate and save the recipe
    // For now, just print the values
    print('Recipe Title: ${_titleController.text}');
    print('Description: ${_descriptionController.text}');
    print('Image URL: ${_imageUrlController.text}');
    print('Prep Time: ${_prepTimeController.text}');
    print('Cook Time: ${_cookTimeController.text}');
    print('Tags: $_selectedTags');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.recipeToEdit != null
            ? 'Recipe updated successfully!'
            : 'Recipe added successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // In a real app, you'd navigate back or reset form
  }
}
