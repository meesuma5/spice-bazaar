
enum SortOption {
  none,
  titleAsc,
  titleDesc,
  ratingDesc,
  ratingAsc,
  prepTimeAsc,
  prepTimeDesc,
  dateDesc,
  dateAsc,
}


class RecipeFilters {
  String? searchQuery;
  List<String> selectedTags = [];
  int? maxPrepTime; // in minutes
  int? maxCookTime; // in minutes
	SortOption sortBy = SortOption.none; 
  
  // Helper method to check if any filters are active
  bool get isActive => 
      (searchQuery != null && searchQuery!.isNotEmpty) || 
      selectedTags.isNotEmpty || 
      maxPrepTime != null || 
      maxCookTime != null ||
			sortBy != SortOption.none;
  
  // Clear all filters
  void reset() {
    searchQuery = null;
    selectedTags = [];
    maxPrepTime = null;
    maxCookTime = null;
		sortBy = SortOption.none;
  }
}