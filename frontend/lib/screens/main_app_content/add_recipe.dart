
import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:spice_bazaar/widgets/custom_button.dart';

class AddRecipeContent extends StatefulWidget {
  final Recipe? recipeToEdit; // Pass recipe to edit (null for new recipe)

  const AddRecipeContent({
    super.key,
    this.recipeToEdit,
  });

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
        TextEditingController(text: widget.recipeToEdit?.image ?? '');
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