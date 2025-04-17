import 'package:spice_bazaar/models/recipe.dart';
import 'package:spice_bazaar/models/users.dart';

class Reviews{
	String? id;
	final String recipeId;
	final String comment;
	final int rating;
	DateTime? createdAt;

	Reviews({
		this.id,
		required this.recipeId,
		required this.comment,
		required this.rating,
		this.createdAt,
	});

	Reviews.fromJson(Map<String, dynamic> json)
		: id = json['review_id'],
		  recipeId = json['recipe'],
		  comment = json['comment'],
		  rating = json['rating'],
		  createdAt = DateTime.parse(json['review_date']);
	// set the review id
	void setId(String id) {
		this.id = id;
	}
	// set the created at date
	void setCreatedAt() {
		createdAt = DateTime.now();
	}
		
}