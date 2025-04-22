import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/ingredient.dart';
import 'package:spice_bazaar/models/recipe.dart';
import 'package:spice_bazaar/models/users.dart';
import 'package:spice_bazaar/services/storage_service.dart';
import 'package:spice_bazaar/widgets/custom_button.dart';

class AddRecipeContent extends StatefulWidget {
  final Recipe? recipeToEdit; // Pass recipe to edit (null for new recipe)
  final User user;
  final Function() back;
	final VoidCallback onRecipeAdded; // Add this callback

  const AddRecipeContent({
    super.key,
    this.recipeToEdit,
    required this.user,
    required this.back,
		required this.onRecipeAdded,
  });

  @override
  State<AddRecipeContent> createState() => _AddRecipeContentState();
}

class _AddRecipeContentState extends State<AddRecipeContent> {
  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _prepTimeController;
  late TextEditingController _cookTimeController;
  TextEditingController _videoLinkController =
      TextEditingController(text: ''); // Initialize with empty string

  String _selectedTags = '';
  String? imageUrl;

  // Course options
  final List<String> _courseOptions = [
    "Appetizer",
    "Main Course",
    "Side Dish",
    "Dessert",
    "Beverage",
    "Breakfast",
    "Lunch",
    "Dinner",
    "Snack",
    "Soup"
  ];
  String _selectedCourse = "Main Course";

  // Diet options
  final List<String> _dietOptions = [
    "Vegetarian",
    "Vegan",
    "Non-Vegetarian",
    "Gluten-Free",
    "Dairy-Free",
    "Keto",
    "Paleo"
  ];
  String _selectedDiet = "Non-Vegetarian";

  // Ingredients list
  List<Ingredient> _ingredients = [];
  // Map<String, String>

  // Instruction steps
  List<String> _instructionSteps = [];

  // Temp controllers for adding ingredients
  final TextEditingController _newIngredientNameController =
      TextEditingController();
  final TextEditingController _newIngredientQtyController =
      TextEditingController();
  final TextEditingController _newIngredientUnitController =
      TextEditingController();

  // Temp controller for adding instruction steps
  final TextEditingController _newInstructionController =
      TextEditingController();

  void init() async {
    // Set selected tags if editing
    if (widget.recipeToEdit != null) {
      final res = await http.get(
          Uri.parse('$baseUrl/api/recipes/view/${widget.recipeToEdit!.recipeId}/'), headers: {
						'Authorization': 'Bearer ${widget.user.accessToken}',
					});
      DetailedRecipe detailedRecipe = DetailedRecipe.fromJson(
        widget.recipeToEdit!,
        json.decode(res.body),
      );

      setState(() {
        _selectedTags = widget.recipeToEdit!.tags[0];
        _videoLinkController =
            TextEditingController(text: detailedRecipe.video_link ?? '');

        // Set course and diet if editing
        if (widget.recipeToEdit!.tags.length > 1) {
          _selectedCourse = widget.recipeToEdit!.tags[1];
        }

        if (widget.recipeToEdit!.tags.length > 2) {
          _selectedDiet = widget.recipeToEdit!.tags[2];
        }

        // Set ingredients and instructions if editing
        _ingredients = List.from(detailedRecipe.ingredients);

        _instructionSteps = List.from(detailedRecipe.instructions);

        // Set image URL if editing
        imageUrl = widget.recipeToEdit!.image;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize controllers with values from recipeToEdit if provided
    _titleController =
        TextEditingController(text: widget.recipeToEdit?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.recipeToEdit?.description ?? '');
    _prepTimeController = TextEditingController(
        text: widget.recipeToEdit?.prepTime != null
            ? widget.recipeToEdit!.getPrepTimeInMinutes()
            : '');
    _cookTimeController = TextEditingController(
        text: widget.recipeToEdit?.cookTime != null
            ? widget.recipeToEdit!.getCookTimeInMinutes()
            : '');
    init();
  }

  final StorageService _storageService = StorageService();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          // You now have the File object (_imageFile) which you can upload to Firebase Storage.
          print('Selected image path: ${_imageFile!.path}');
          _storageService.uploadFile(_imageFile!.path, _imageFile!).then((url) {
            setState(() {
              imageUrl = url;
              print(imageUrl);
            });
          }).catchError((error) {
            print('Error uploading image: $error');
          });
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _videoLinkController.dispose();
    _newIngredientNameController.dispose();
    _newIngredientQtyController.dispose();
    _newIngredientUnitController.dispose();
    _newInstructionController.dispose();
    super.dispose();
  }

  // Format time string to HH:MM:SS
  String _formatTimeString(String minutes) {
    if (minutes.isEmpty) return "00:00:00";

    try {
      int mins = int.parse(minutes);
      int hours = mins ~/ 60;
      int remainingMins = mins % 60;
      return "${hours.toString().padLeft(2, '0')}:${remainingMins.toString().padLeft(2, '0')}:00";
    } catch (e) {
      return "00:00:00";
    }
  }

  // Add new ingredient to the list
  void _addIngredient() {
    if (_newIngredientNameController.text.isNotEmpty &&
        _newIngredientQtyController.text.isNotEmpty) {
      setState(() {
        _ingredients.add(Ingredient.fromJson({
          "item": _newIngredientNameController.text,
          "quantity":
              "${_newIngredientQtyController.text} ${_newIngredientUnitController.text}"
        }));

        // Clear the controllers
        _newIngredientNameController.clear();
        _newIngredientQtyController.clear();
        _newIngredientUnitController.clear();
      });
    }
  }

  // Add new instruction step
  void _addInstructionStep() {
    if (_newInstructionController.text.isNotEmpty) {
      setState(() {
        _instructionSteps.add(_newInstructionController.text);
        _newInstructionController.clear();
      });
    }
  }

  // Remove ingredient at index
  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  // Remove instruction at index
  void _removeInstruction(int index) {
    setState(() {
      _instructionSteps.removeAt(index);
    });
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
          const SizedBox(height: 16),
          // Image picker
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
                border: Border.all(color: borderGray),
                image: _imageFile != null
                    ? DecorationImage(
                        image: FileImage(_imageFile!), fit: BoxFit.cover)
                    : widget.recipeToEdit?.image != null
                        ? DecorationImage(
                            image: NetworkImage(widget.recipeToEdit!.image!),
                            fit: BoxFit.cover)
                        : null,
              ),
              child: (_imageFile == null &&
                      (widget.recipeToEdit?.image == null ||
                          widget.recipeToEdit?.image == ''))
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add Recipe Photo',
                          style: poppins(
                              style: TextStyle(color: Colors.grey[600])),
                        )
                      ],
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          // Form fields
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: Border.all(color: borderGray),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recipe Details',
                    style: poppins(
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                const SizedBox(height: 16),

                // Title
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
                const SizedBox(height: 16),

                // Video link
                _buildTextField(
                  controller: _videoLinkController,
                  label: 'Video Link (Optional)',
                  hintText: 'e.g. https://example.com/your-recipe-video',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: Border.all(color: borderGray),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recipe Type',
                    style: poppins(
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                const SizedBox(height: 16),
                // Course dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Type',
                      style: poppins(
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCourse,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          style: poppins(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCourse = newValue!;
                            });
                          },
                          items: _courseOptions
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: poppins(
                                      style: const TextStyle(
                                          color: Colors.black87))),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Diet dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diet Type',
                      style: poppins(
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        border: Border.all(color: borderGray),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDiet,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          style: poppins(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDiet = newValue!;
                            });
                          },
                          items: _dietOptions
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: poppins(
                                    style:
                                        const TextStyle(color: Colors.black87)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Ingredients section
          _buildIngredientsSection(),
          const SizedBox(height: 24),

          // Instructions section
          _buildInstructionsSection(),
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
          const SizedBox(height: 40),
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
            hintStyle: poppins(),
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
        final isSelected = (_selectedTags == tag);

        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedTags = tag;
              } else {
                _selectedTags = '';
              }
            });
          },
          backgroundColor: Colors.white,
          selectedColor: lighterPurple,
          checkmarkColor: mainPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? mainPurple : Colors.grey[300]!,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIngredientsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingredients',
            style: poppins(
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),

          // Ingredient list
          ..._ingredients.asMap().entries.map((entry) {
            final ingredient = entry.value;
            return Column(
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        ingredient.item,
                        style: poppins(style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(ingredient.quantity,
                            style: poppins(
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            )),
                      ),
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.close, color: Colors.grey[600], size: 20),
                      onPressed: () => _removeIngredient(entry.key),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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
            );
          }),

          const SizedBox(height: 16),

          // Add new ingredient fields
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Ingredient name
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _newIngredientNameController,
                  decoration: InputDecoration(
                    hintText: 'Ingredient name',
                    hintStyle: poppins(),
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
                ),
              ),
              const SizedBox(width: 8),

              // Quantity
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _newIngredientQtyController,
                  decoration: InputDecoration(
                    hintText: 'Qty',
                    hintStyle: poppins(),
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
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),

              // Unit
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _newIngredientUnitController,
                  decoration: InputDecoration(
                    hintText: 'Unit',
                    hintStyle: poppins(),
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
                ),
              ),
            ],
          ),

          // Add ingredient button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextButton.icon(
              icon: const Icon(Icons.add),
              label: Text(
                'Add Ingredient',
                style: poppins(),
              ),
              onPressed: _addIngredient,
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructions',
            style: poppins(
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),

          // Instruction steps list
          ..._instructionSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8, top: 2),
                    decoration: const BoxDecoration(
                      color: lighterPurple,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: poppins(
                          style: const TextStyle(
                            color: mainPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      step,
                      style: poppins(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
                    onPressed: () => _removeInstruction(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // Add new instruction field
          TextField(
            controller: _newInstructionController,
            decoration: InputDecoration(
              hintText: 'Type instruction step here',
              hintStyle: poppins(),
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
            maxLines: 3,
          ),

          // Add instruction button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextButton.icon(
              icon: const Icon(Icons.add),
              label: Text(
                'Add Step',
                style: poppins(),
              ),
              onPressed: _addInstructionStep,
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRecipe() async {
    // Validate the form
    if (_titleController.text.isEmpty) {
      _showErrorSnackBar('Please enter a recipe title');
      return;
    }

    if (_selectedTags == '') {
      _showErrorSnackBar('Please select exactly one cuisine tag');
      return;
    }

    if (_ingredients.isEmpty) {
      _showErrorSnackBar('Please add at least one ingredient');
      return;
    }

    if (_instructionSteps.isEmpty) {
      _showErrorSnackBar('Please add at least one instruction step');
      return;
    }

    // Format the time strings
    String formattedPrepTime = _formatTimeString(_prepTimeController.text);
    String formattedCookTime = _formatTimeString(_cookTimeController.text);
    List ingredientsList = [];
    for (var ingredient in _ingredients) {
      ingredientsList.add(ingredient.toJson());
    }
    // Prepare the recipe data
    Map<String, dynamic> recipeData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'prep_time': formattedPrepTime,
      'cook_time': formattedCookTime,
      'cuisine': _selectedTags, // Using first tag as primary cuisine
      'course': _selectedCourse,
      'diet': _selectedDiet,
      'ingredients': jsonEncode(ingredientsList),
      'instructions': jsonEncode(_instructionSteps),
      'image': imageUrl ?? '',
      'video_link': _videoLinkController.text
    };

    // Add video link if provided
    if (_videoLinkController.text.isNotEmpty) {
      recipeData['video_link'] = _videoLinkController.text;
    }

    try {
      // Get the user's authentication token

      // Set up the headers
      Map<String, String> headers = {
        'Authorization': 'Bearer ${widget.user.accessToken}',
      };

      // Prepare the URI
      Uri uri;
      http.Response response;

      // Make the appropriate request based on whether we're adding or editing
      if (widget.recipeToEdit == null) {
        // POST request for a new recipe
        uri = Uri.parse('$baseUrl/api/recipes/upload/');
        response = await http.post(
          uri,
          headers: headers,
          body: recipeData,
        );
				widget.user.createdRecipes += 1;
      } else {
        // PUT request to update an existing recipe
        uri =
            Uri.parse('$baseUrl/api/recipes/edit/${widget.recipeToEdit!.recipeId}/');
        response = await http.put(
          uri,
          headers: headers,
          body: recipeData,
        );
      }

      // Handle the response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.recipeToEdit != null
                ? 'Recipe updated successfully!'
                : 'Recipe added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back or reset form
        widget.back();
      } else {
        // Show error message
        _showErrorSnackBar('Error: ${response.body}');
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
      print('Error: $e'); // Log the error for debugging
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
