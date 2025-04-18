import 'package:spice_bazaar/models/recipe.dart';
import 'package:spice_bazaar/models/users.dart';

class Reviews {
  String? id;
  final String comment;
  final int rating;
  final String username;
  DateTime? createdAt;

  Reviews({
    this.id,
    required this.comment,
    required this.rating,
    this.createdAt,
    required this.username,
  });

  Reviews.fromJson(Map<String, dynamic> json)
      : id = json['review_id'],
        comment = json['comment'] ?? '',
        username = json['username'] ?? '',
        rating = json['rating'] ?? 0,
        createdAt = json['review_date'] != null
            ? DateTime.parse(json['review_date'])
            : null;

  // set the review id
  void setId(String id) {
    this.id = id;
  }

  // set the created at date
  void setCreatedAt() {
    createdAt = DateTime.now();
  }
}
