import 'package:spice_bazaar/models/ingredient.dart';
import 'package:spice_bazaar/models/reviews.dart';

class Recipe {
  final String recipeId;
  final String title;
  final String description;
  final List<String> tags;
  final String prepTime;
  final String? cookTime;
  final String uploadDate;
  final String author;
  final String? image; // Mark as nullable with ?
  bool isBookmarked;

  Recipe({
    required this.recipeId,
    required this.title,
    required this.description,
    required this.tags,
    required this.prepTime,
    required this.uploadDate,
    required this.author,
    required this.isBookmarked,
    this.cookTime, // Optional cook time
    this.image, // Handle nullable image
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
        recipeId: json['recipe_id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        prepTime: json['time'].toString(),
        cookTime: json['cook_time'].toString(),
        uploadDate: json['upload_date'] ?? '',
        author: json['author'] ?? '',
        image: json['image'],
        isBookmarked:
            json["is_bookmarked"] // No default needed as it's nullable
        );
  }
  Map<String, dynamic> toJson() {
    return {
      'recipe_id': recipeId,
      'title': title,
      'description': description,
      'tags': tags,
      'time': prepTime,
      'cook_time': cookTime, // Include cook time if available
      'upload_date': uploadDate,
      'author': author,
      'image': image, // Include image if available
    };
  }

  String get formattedPrepTime {
    // Check if prepTime is in minutes (integer) or time format (HH:MM:SS)
    int hours;
    int minutes;
    if (RegExp(r'^\d+$').hasMatch(prepTime)) {
      // It's an integer (minutes)
      hours = int.parse(prepTime) ~/ 60;
      minutes = int.parse(prepTime) % 60;
    } else if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(prepTime)) {
      // It's in time format HH:MM:SS
      final parts = prepTime.split(':');
      hours = int.parse(parts[0]);
      minutes = int.parse(parts[1]);
    } else {
      return prepTime; // Return as is if format is unknown
    }
    if (hours == 0 && minutes == 0) {
      return 'N/A'; // Handle case where both hours and minutes are zero
    } else if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }

  String get formattedCookTime {
    if (cookTime == null || cookTime!.isEmpty) {
      return 'N/A'; // Handle null or empty cook time
    }
    int hours;
    int minutes;
    // Check if cookTime is in minutes (integer) or time format (HH:MM:SS)
    if (RegExp(r'^\d+$').hasMatch(cookTime!)) {
      // It's an integer (minutes)
      hours = int.parse(cookTime!) ~/ 60;
      minutes = int.parse(cookTime!) % 60;
    } else if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(cookTime!)) {
      // It's in time format HH:MM:SS
      final parts = cookTime!.split(':');
      hours = int.parse(parts[0]);
      minutes = int.parse(parts[1]);
    } else {
      return cookTime!; // Return as is if format is unknown
    }
    if (hours == 0 && minutes == 0) {
      return 'N/A'; // Handle case where both hours and minutes are zero
    } else if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }

  String get formattedUploadDate {
    final date = DateTime.parse(uploadDate);
    return '${date.day}/${date.month}/${date.year}';
  }

  String get formattedTags {
    return tags.join(', ');
  }

  Recipe copyWith({
    String? recipeId,
    String? title,
    String? description,
    List<String>? tags,
    String? prepTime,
    String? cookTime,
    String? uploadDate,
    String? author,
    String? image,
    bool? isBookmarked,
  }) {
    return Recipe(
      recipeId: recipeId ?? this.recipeId,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      uploadDate: uploadDate ?? this.uploadDate,
      author: author ?? this.author,
      image: image ?? this.image,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  void toggleBookmark() {
    isBookmarked = !isBookmarked;
  }

  String getPrepTimeInMinutes() {
    if (RegExp(r'^\d+$').hasMatch(prepTime)) {
      // It's an integer (minutes)
      return (int.parse(prepTime)).toString();
    } else if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(prepTime)) {
      // It's in time format HH:MM:SS
      final parts = prepTime.split(':');
      return (int.parse(parts[0]) * 60 + int.parse(parts[1])).toString();
    }
    return '0'; // Default to 0 if format is unknown
  }

  String getCookTimeInMinutes() {
    if (cookTime == null || cookTime!.isEmpty) {
      return '0'; // Handle null or empty cook time
    }
    if (RegExp(r'^\d+$').hasMatch(cookTime!)) {
      // It's an integer (minutes)
      return (int.parse(cookTime!)).toString();
    } else if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(cookTime!)) {
      // It's in time format HH:MM:SS
      final parts = cookTime!.split(':');
      return (int.parse(parts[0]) * 60 + int.parse(parts[1])).toString();
    }
    return '0'; // Default to 0 if format is unknown
  }
}

class DetailedRecipe {
  final Recipe recipe;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final String? video_link;
  List<Reviews> reviews = [];
  Reviews? userReview;
  DetailedRecipe({
    required this.recipe,
    required List<dynamic> ingredients,
    required this.instructions,
    this.video_link,
    this.userReview,
    List<Reviews>? reviews,
  })  : ingredients = ingredients
            .map((ingredientJson) => Ingredient.fromJson(ingredientJson))
            .toList(),
        reviews = reviews ?? [];
  factory DetailedRecipe.fromJson(Recipe recipe, Map<String, dynamic> json) {
    return DetailedRecipe(
      recipe: recipe,
      ingredients: json['ingredients'] ?? [],
      instructions: List<String>.from(json['instructions'] ?? []),
      video_link: json['video_link'],
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
              .map((reviewJson) => Reviews.fromJson(reviewJson))
              .toList()
          : [],
      userReview: json['your_review'] != null
          ? Reviews.fromJson(json['your_review'])
          : null,
    );
  }
  void addReview(Reviews review) {
    reviews ??= [];
    reviews!.add(review);
  }

  void updateReview(Reviews review) {
    if (reviews != null) {
      int index = reviews!.indexWhere((r) => r.id == review.id);
      if (index != -1) {
        reviews![index] = review;
      }
    }
  }

  void removeReview(Reviews review) {
    if (reviews != null) {
      reviews!.remove(review);
    }
  }
}
