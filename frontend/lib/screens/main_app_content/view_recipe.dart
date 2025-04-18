import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:spice_bazaar/models/reviews.dart';
import 'package:spice_bazaar/models/users.dart';
import 'package:spice_bazaar/widgets/custom_button.dart';
import 'package:spice_bazaar/widgets/favourite_button.dart';
import 'package:uicons_updated/uicons.dart';
import 'package:http/http.dart' as http;

class RecipeDetailContent extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback onBack;
  final User user;
  final Function(Recipe recipe) onBookmark;
  final Function(Recipe recipe) onEdit;
  final Function(Recipe recipe) onDelete;
  // Constructor to initialize the recipe and the back function

  const RecipeDetailContent({
    super.key,
    required this.recipe,
    required this.onBack,
    required this.user,
    required this.onBookmark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<RecipeDetailContent> createState() => _RecipeDetailContentState();
}

class _RecipeDetailContentState extends State<RecipeDetailContent> {
  DetailedRecipe? detailedRecipe;
  late Recipe recipe;
  String imageUrl = baseRecipeImageLink;

  void init() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/recipes/view/${widget.recipe.recipeId}/'),
      headers: {
        'Authorization': 'Bearer ${widget.user.accessToken}',
      },
    );
    print(json.decode(response.body)['your_review']);
    print(json.decode(response.body)['reviews']);
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
    imageUrl = recipe.image != null && recipe.image!.isNotEmpty
        ? widget.recipe.image!
        : baseRecipeImageLink;
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
                      imageUrl,
                    ),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Cannot return a DecorationImage in onError callback as it expects void
                      setState(() {
                        imageUrl = baseRecipeImageLink;
                      });
                    },
                  ),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FavouriteButton(
                            recipe: recipe, onBookmark: widget.onBookmark),
                        (detailedRecipe != null &&
                                recipe.author == widget.user.username)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
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
                              )
                            : const SizedBox(),
                      ],
                    ))),
          ),
        ),
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
                if (recipe.tags.length > 2)
                  _buildInfoChip(
                      UiconsRegular.room_service, 'Course: ${recipe.tags[1]}'),
                if (recipe.tags.length > 3)
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

        // Reviews Section
        SliverToBoxAdapter(
          child: _buildSection(
            'Reviews',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User's review input or existing review
                _buildUserReviewSection(),

                // Divider between user's review and other reviews
                if (detailedRecipe != null &&
                    (detailedRecipe!.userReview != null ||
                        detailedRecipe!.reviews.isNotEmpty))
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Divider(color: borderGray, thickness: 1),
                  ),

                // Other reviews
                if (detailedRecipe != null)
                  for (var review in detailedRecipe!.reviews)
                    _buildReviewItem(review),
                const SizedBox(height: 16),
                // Message if no reviews
                if (detailedRecipe != null)
                  if (detailedRecipe!.reviews.isEmpty &&
                      detailedRecipe!.userReview == null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'Be the first to review this recipe!',
                          style: poppins(
                              style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          )),
                        ),
                      ),
                    )
                  else
                    const SizedBox(
                      height: 16,
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
          child: SizedBox(height: 16),
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

  Widget _buildUserReviewSection() {
    if (detailedRecipe == null) return const SizedBox.shrink();

    // If user has already submitted a review, show it with edit/delete options
    if (detailedRecipe!.userReview != null) {
      return _buildReviewItem(
        detailedRecipe!.userReview!,
        isUserReview: true,
        onEdit: () => _showReviewDialog(isEdit: true),
        onDelete: _deleteUserReview,
      );
    }
    // Otherwise show option to add a review
    else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomButton(
          buttonColor: mainPurple,
          vPad: 12,
          hPad: 16,
          text: 'Write a Review',
          color: Colors.white,
          textStyle: poppins(
              style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          )),
          onPressed: () => _showReviewDialog(),
          icon: const Icon(UiconsRegular.comment_alt_edit, color: Colors.white),
        ),
      );
    }
  }

  Widget _buildReviewItem(
    Reviews review, {
    bool isUserReview = false,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: isUserReview ? lighterPurple.withOpacity(0.3) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGray.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User info and rating
              Expanded(
                child: Row(
                  children: [
                    const Icon(UiconsRegular.user, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        review.username,
                        style: poppins(
                            style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildRatingStars(review.rating),
                  ],
                ),
              ),

              // Edit/Delete buttons for user's own review
              if (isUserReview && onEdit != null && onDelete != null)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(UiconsRegular.pencil, size: 18),
                      onPressed: onEdit,
                      color: mainPurple,
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(UiconsRegular.trash, size: 18),
                      onPressed: onDelete,
                      color: Colors.red,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
            ],
          ),

          // Review date
          Padding(
            padding: const EdgeInsets.only(left: 26.0, bottom: 8.0),
            child: Text(
              _formatDate(review.createdAt!),
              style: poppins(
                  style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              )),
            ),
          ),

          // Review content
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              review.comment,
              style: poppins(
                  style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? UiconsSolid.star : UiconsRegular.star,
          color: index < rating ? Colors.amber : Colors.grey[400],
          size: 16,
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showReviewDialog({bool isEdit = false}) {
    final TextEditingController reviewController = TextEditingController();
    int selectedRating = 5;

    if (isEdit && detailedRecipe?.userReview != null) {
      reviewController.text = detailedRecipe!.userReview!.comment;
      selectedRating = detailedRecipe!.userReview!.rating;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                isEdit ? 'Edit Your Review' : 'Write a Review',
                style: poppins(
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating selector
                  Text(
                    'Your Rating:',
                    style: poppins(
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating
                              ? UiconsSolid.star
                              : UiconsRegular.star,
                          color: index < selectedRating
                              ? Colors.amber
                              : Colors.grey[400],
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Review text input
                  Text(
                    'Your Review:',
                    style: poppins(
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reviewController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts about this recipe...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: poppins(style: TextStyle(color: Colors.grey[700])),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainPurple,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (isEdit) {
                      _updateUserReview(reviewController.text, selectedRating);
                    } else {
                      _submitUserReview(reviewController.text, selectedRating);
                    }
                  },
                  child: Text(
                    isEdit ? 'Update' : 'Submit',
                    style: poppins(style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitUserReview(String comment, int rating) async {
    if (comment.trim().isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/reviews/upload/'),
        headers: {
          'Authorization': 'Bearer ${widget.user.accessToken}',
        },
        body: {
          'recipe': recipe.recipeId,
          'comment': comment,
          'rating': rating.toString(),
        },
      );

      if (response.statusCode == 201) {
        // Refresh recipe details to show the new review
        init();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Review submitted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _updateUserReview(String comment, int rating) async {
    if (comment.trim().isEmpty || detailedRecipe?.userReview == null) return;

    try {
      final response = await http.put(
        Uri.parse(
            '$baseUrl/api/reviews/edit/${detailedRecipe!.userReview!.id}/'),
        headers: {
          'Authorization': 'Bearer ${widget.user.accessToken}',
        },
        body: {
          'comment': comment,
          'rating': rating.toString(),
        },
      );

      if (response.statusCode == 200) {
        // Refresh recipe details to show updated review
        init();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Review updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update review')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _deleteUserReview() async {
    if (detailedRecipe?.userReview == null) return;

    // Show confirmation dialog
    final bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Review?', style: poppins()),
            content: Text('Are you sure you want to delete your review?',
                style: poppins()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: poppins()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete',
                    style: poppins(style: const TextStyle(color: Colors.red))),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/api/reviews/delete/${detailedRecipe!.userReview!.id}/'),
        headers: {
          'Authorization': 'Bearer ${widget.user.accessToken}',
        },
      );

      if (response.statusCode == 204) {
        // Refresh recipe details
        init();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Review deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete review')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
