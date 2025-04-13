import 'package:spice_bazaar/constants.dart';

class User {
  final String username;
  final String email;
  final int createdRecipes;
  final int bookmarkedRecipes;
  final String accessToken;
  final String refreshToken;
  final String? profileImageUrl;
  final String regDate;

  User({
    required this.username,
    required this.email,
    required this.createdRecipes,
    required this.bookmarkedRecipes,
    required this.accessToken,
    required this.refreshToken,
    required this.regDate,
    this.profileImageUrl,
  });

  // Create a User from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      email: json['email'] as String,
      createdRecipes: json['recipe_count'] as int,
      bookmarkedRecipes: json['bookmark_count'] as int,
      accessToken: json['access'] as String,
      refreshToken: json['refresh'] as String,
      profileImageUrl: json['image_link'] as String?,
      regDate: formatDate(json['reg_date'] as String),
    );
  }

  // Convert User to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'createdRecipes': createdRecipes,
      'bookmarkedRecipes': bookmarkedRecipes,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'profileImageUrl': profileImageUrl,
      'regDate': regDate,
    };
  }

  // Get access token
  String getAccessToken() {
    return accessToken;
  }

  // Get refresh token
  String getRefreshToken() {
    return refreshToken;
  }

  // Create a copy of User with some updated fields
  // User copyWith({
  // 	String? id,
  // 	String? username,
  // 	String? email,
  // 	int? createdRecipes,
  // 	int? bookmarkedRecipes,
  // }) {
  // 	return User(
  // 		id: id ?? this.id,
  // 		username: username ?? this.username,
  // 		email: email ?? this.email,
  // 		createdRecipes: createdRecipes ?? this.createdRecipes,
  // 		bookmarkedRecipes: bookmarkedRecipes ?? this.bookmarkedRecipes,
  // 	);
  // }
}
