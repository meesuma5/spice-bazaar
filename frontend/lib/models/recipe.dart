class Recipe {
  final String recipeId;
  final String title;
  final String description;
  final List<String> tags;
  final int prepTime;
  final int? cookTime;
  final String uploadDate;
  final String author;
  final String? image; // Mark as nullable with ?

  Recipe({
    required this.recipeId,
    required this.title,
    required this.description,
    required this.tags,
    required this.prepTime,
    required this.uploadDate,
    required this.author,
		this.cookTime, // Optional cook time
    this.image, // Handle nullable image
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      recipeId: json['recipe_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      prepTime: json['time'] ?? 0,
			cookTime: json['cook_time'], // No default needed as it's nullable
      uploadDate: json['upload_date'] ?? '',
      author: json['author'] ?? '',
      image: json['image'], // No default needed as it's nullable
    );
  }
}
