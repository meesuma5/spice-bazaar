import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:uicons/uicons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? recipeToEdit; // If provided, we're in edit mode

  const AddRecipeScreen({this.recipeToEdit, super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final prepTimeController = TextEditingController();
  final cookTimeController = TextEditingController();
  String selectedCuisine = 'Italian';
  List<String> tags = [];
  File? imageFile;
  String? imageUrl;
  bool isLoading = false;

  // Available cuisine types
  final List<String> cuisineTypes = [
    'Italian',
    'Mexican',
    'Indian',
    'Thai',
    'Japanese',
    'Chinese',
    'French',
    'American',
    'Mediterranean',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.recipeToEdit != null) {
      // Populate form with recipe data for editing
      titleController.text = widget.recipeToEdit!.title;
      descriptionController.text = widget.recipeToEdit!.description;
      prepTimeController.text = widget.recipeToEdit!.prepTime.toString();
      cookTimeController.text = widget.recipeToEdit!.cookTime.toString();

      if (widget.recipeToEdit!.tags.isNotEmpty) {
        selectedCuisine = widget.recipeToEdit!.tags.first;
        tags = widget.recipeToEdit!.tags.skip(1).toList();
      }

      imageUrl = widget.recipeToEdit!.imageUrl;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    prepTimeController.dispose();
    cookTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        imageUrl = null; // Clear the URL since we now have a file
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // In a real app, upload the image first if we have one
        // String? uploadedImageUrl;
        // if (imageFile != null) {
        //   uploadedImageUrl = await _uploadImage(imageFile!);
        // }

        // Prepare recipe data
        final recipeData = {
          "title": titleController.text,
          "description": descriptionController.text,
          "tags": [selectedCuisine, ...tags],
          "prep_time": int.parse(prepTimeController.text),
          "cook_time": int.parse(cookTimeController.text),
          "image_url": imageUrl ??
              "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3", // Fallback image
          "author": "You" // In a real app, get from user profile
        };

        // In a real app, send to API
        // final response = widget.recipeToEdit == null
        //     ? await http.post(
        //         Uri.parse('https://api.spicebazaar.com/api/recipes'),
        //         headers: {
        //           'Content-Type': 'application/json',
        //           'Authorization': 'Bearer $token'
        //         },
        //         body: jsonEncode(recipeData),
        //       )
        //     : await http.put(
        //         Uri.parse('https://api.spicebazaar.com/api/recipes/${widget.recipeToEdit!.id}'),
        //         headers: {
        //           'Content-Type': 'application/json',
        //           'Authorization': 'Bearer $token'
        //         },
        //         body: jsonEncode(recipeData),
        //       );

        // Simulate API delay
        await Future.delayed(const Duration(seconds: 1));

        // Success! Go back to previous screen
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } catch (e) {
        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving recipe: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !tags.contains(tag)) {
      setState(() {
        tags.add(tag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.recipeToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Recipe' : 'Add New Recipe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Picker
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                            image: imageFile != null
                                ? DecorationImage(
                                    image: FileImage(imageFile!),
                                    fit: BoxFit.cover,
                                  )
                                : imageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(imageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                          ),
                          child: imageFile == null && imageUrl == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 50,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add Recipe Photo',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title Field
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Recipe Title*',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a recipe title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description*',
                        border: OutlineInputBorder(),
                        hintText: 'Describe your recipe in a few sentences',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Cuisine Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedCuisine,
                      decoration: const InputDecoration(
                        labelText: 'Cuisine Type*',
                        border: OutlineInputBorder(),
                      ),
                      items: cuisineTypes.map((String cuisine) {
                        return DropdownMenuItem<String>(
                          value: cuisine,
                          child: Text(cuisine),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCuisine = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tags Section
                    const Text(
                      'Tags (optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Add a tag (e.g., Spicy, Vegetarian)',
                              border: OutlineInputBorder(),
                            ),
                            onFieldSubmitted: (value) {
                              _addTag(value);
                              // Clear the field
                              final controller = TextEditingController();
                              controller.clear();
                            },
                          ),
                        ),
                      ],
                    ),
                    if (tags.isNotEmpty) const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeTag(tag),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Prep and Cook Time
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: prepTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Prep Time (min)*',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Enter a number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: cookTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Cook Time (min)*',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Enter a number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveRecipe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[300],
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          isEditMode ? 'Update Recipe' : 'Save Recipe',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
