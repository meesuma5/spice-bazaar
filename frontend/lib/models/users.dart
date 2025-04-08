class User {
	final String id;
	final String username;
	final String email;
	final List<String> createdRecipeIds;
	final List<String> bookmarkedRecipeIds;

	User({
		required this.id,
		required this.username,
		required this.email,
		List<String>? createdRecipeIds,
		List<String>? bookmarkedRecipeIds,
	}) : 
		createdRecipeIds = createdRecipeIds ?? [],
		bookmarkedRecipeIds = bookmarkedRecipeIds ?? [];

	// Create a User from a JSON map
	factory User.fromJson(Map<String, dynamic> json) {
		return User(
			id: json['id'] as String,
			username: json['username'] as String,
			email: json['email'] as String,
			createdRecipeIds: (json['createdRecipeIds'] as List<dynamic>?)
					?.map((e) => e as String)
					.toList(),
			bookmarkedRecipeIds: (json['bookmarkedRecipeIds'] as List<dynamic>?)
					?.map((e) => e as String)
					.toList(),
		);
	}

	// Convert User to a JSON map
	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'username': username,
			'email': email,
			'createdRecipeIds': createdRecipeIds,
			'bookmarkedRecipeIds': bookmarkedRecipeIds,
		};
	}

	// Create a copy of User with some updated fields
	User copyWith({
		String? id,
		String? username,
		String? email,
		List<String>? createdRecipeIds,
		List<String>? bookmarkedRecipeIds,
	}) {
		return User(
			id: id ?? this.id,
			username: username ?? this.username,
			email: email ?? this.email,
			createdRecipeIds: createdRecipeIds ?? this.createdRecipeIds,
			bookmarkedRecipeIds: bookmarkedRecipeIds ?? this.bookmarkedRecipeIds,
		);
	}
}