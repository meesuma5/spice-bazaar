class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> tags;
  final int prepTime;
  final int cookTime;
  final double rating;
  final String author;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.tags,
    required this.prepTime,
    required this.cookTime,
    required this.rating,
    required this.author,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      tags: List<String>.from(json['tags']),
      prepTime: json['prep_time'],
      cookTime: json['cook_time'],
      rating: json['rating'].toDouble(),
      author: json['author'],
    );
  }

  int get totalTime => prepTime + cookTime;
}