import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:spice_bazaar/models/users.dart';
import 'package:spice_bazaar/widgets/avatar_icon.dart';
import 'package:spice_bazaar/widgets/custom_button.dart';
import 'package:uicons/uicons.dart';
import 'package:uicons_updated/uicons.dart';
import 'package:http/http.dart' as http;

class RecipeDetailContent extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback onBack;
  final User user;
	final Function(Recipe recipe) onEdit;
	final Function(Recipe recipe) onDelete;
  // Constructor to initialize the recipe and the back function

  const RecipeDetailContent({
    super.key,
    required this.recipe,
    required this.onBack,
    required this.user,
		required this.onEdit,
		required this.onDelete,
  });

  @override
  State<RecipeDetailContent> createState() => _RecipeDetailContentState();
}

class _RecipeDetailContentState extends State<RecipeDetailContent> {
  DetailedRecipe? detailedRecipe;
  late Recipe recipe;

  void init() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/recipes/view/${widget.recipe.recipeId}/'),
      headers: {
        'Authorization': 'Bearer ${widget.user.accessToken}',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        recipe = widget.recipe.copyWith(
          cookTime: json.decode(response.body)['cook_time'].toString(),
          prepTime: json.decode(response.body)['prep_time'].toString(),
        );
        detailedRecipe =
            DetailedRecipe.fromJson(widget.recipe, json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load recipe details');
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the recipe
    recipe = widget.recipe;
    init();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Hero Image
        SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(
                      widget.recipe.image ?? baseRecipeImageLink,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: detailedRecipe != null &&
                        recipe.author == widget.user.username
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AvatarIcon(
                              size: 45,
                              icon: UiconsRegular.bookmark,
                              onTap: () {},
                              backgroundColor: Colors.grey[100]!,
                              iconColor: Colors.black87,
                              iconSize: 18,
                            ),
                            const SizedBox(width: 8),
                            CustomButton(
                                vPad: 12,
                                hPad: 12,
                                buttonColor: Colors.grey[100],
                                text: 'Edit Recipe',
                                onPressed: () => widget.onEdit(recipe),
                                textStyle: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                                icon: const Icon(UiconsRegular.pencil,
                                    color: Colors.black87, size: 18)),
                            const SizedBox(width: 8),
                            CustomButton(
                              vPad: 12,
                              hPad: 12,
                              buttonColor: Colors.red,
                              text: 'Delete',
                              color: Colors.white,
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                              onPressed: () => widget.onDelete(recipe),
                              icon: const Icon(UiconsRegular.trash,
                                  color: Colors.white, size: 18),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ),),
            // Recipe Title and Bookmark
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.recipe.title,
                        style: poppins(
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(UIcons.regularRounded.bookmark),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

        // Recipe Info Tags
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(UiconsRegular.time_forward,
                    'Prep: ${recipe.formattedPrepTime}'),
                _buildInfoChip(UiconsRegular.time_check,
                    'Cook: ${recipe.formattedCookTime}'),
                _buildInfoChip(
                    UiconsRegular.room_service, 'Course: ${recipe.tags[1]}'),
                _buildInfoChip(UiconsRegular.restaurant, recipe.tags[2]),
              ],
            ),
          ),
        ),

        // Description Section
        SliverToBoxAdapter(
          child: _buildSection(
            'Description',
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.recipe.description,
                style:
                    poppins(style: const TextStyle(fontSize: 16, height: 1.5)),
              ),
            ),
          ),
        ),

        // Ingredients Section
        SliverToBoxAdapter(
          child: _buildSection(
            'Ingredients',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detailedRecipe != null)
                  for (var ingredient in detailedRecipe!.ingredients)
                    _buildIngredientRow(ingredient.item, ingredient.quantity),
              ],
            ),
          ),
        ),

        // Instructions Section
        SliverToBoxAdapter(
          child: _buildSection(
            'Instructions',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detailedRecipe != null)
                  for (var i = 0; i < detailedRecipe!.instructions.length; i++)
                    _buildInstructionStep(
                      i + 1,
                      detailedRecipe!.instructions[i],
                    ),
              ],
            ),
          ),
        ),

        // Recipe Author
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Icon(UiconsRegular.user_chef, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Recipe by ${recipe.author}',
                  style: poppins(style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),

        // Bottom padding for scroll
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  // Helper methods remain the same as in my previous response
  Widget _buildSection(String title, Widget content) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: poppins(
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: lighterPurple,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: poppins()),
        ],
      ),
    );
  }

  Widget _buildIngredientRow(String ingredient, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  ingredient,
                  style: poppins(style: const TextStyle(fontSize: 16)),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(amount,
                    style: poppins(
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
            color: borderGray,
            height: 2,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(int number, String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: mainPurple, // Purple color from the design
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  instruction,
                  style: poppins(
                      style: const TextStyle(fontSize: 16, height: 1.5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
            color: borderGray,
            height: 2,
            thickness: 1,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
