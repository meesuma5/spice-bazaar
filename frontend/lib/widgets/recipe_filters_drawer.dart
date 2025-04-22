// filter_drawer.dart
import 'package:flutter/material.dart';
import 'package:spice_bazaar/constants.dart';
import 'package:spice_bazaar/models/recipe_filters.dart';
import 'package:uicons_updated/uicons.dart';

class FilterDrawer extends StatefulWidget {
  final RecipeFilters filters;
  final List<String> availableTags;
  final Function(RecipeFilters) onFiltersChanged;
  final void Function() onApply;

  const FilterDrawer({
    Key? key,
    required this.filters,
    required this.availableTags,
    required this.onFiltersChanged,
    required this.onApply,
  }) : super(key: key);

  @override
  _FilterDrawerState createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  late RecipeFilters _currentFilters;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _currentFilters = RecipeFilters()
      ..searchQuery = widget.filters.searchQuery
      ..selectedTags = List.from(widget.filters.selectedTags)
      ..maxPrepTime = widget.filters.maxPrepTime
			..sortBy = widget.filters.sortBy
      ..maxCookTime = widget.filters.maxCookTime;
    _searchController =
        TextEditingController(text: _currentFilters.searchQuery);
  }

  String getSortOptionName(SortOption option) {
    switch (option) {
      case SortOption.none:
        return 'None';
      case SortOption.titleAsc:
        return 'Title A-Z';
      case SortOption.titleDesc:
        return 'Title Z-A';
      case SortOption.ratingDesc:
        return 'Highest Rating';
      case SortOption.ratingAsc:
        return 'Lowest Rating';
      case SortOption.prepTimeAsc:
        return 'Quickest Prep';
      case SortOption.prepTimeDesc:
        return 'Longest Prep';
      case SortOption.dateDesc:
        return 'Newest First';
      case SortOption.dateAsc:
        return 'Oldest First';
      default:
        return 'Unknown';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text('Filter Recipes',
                style: poppins(
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                )),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(UiconsRegular.cross, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Search field
                  TextField(
                    style: poppins(),
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search recipes',
                      labelStyle: poppins(),
                      hintText: 'Search by title or description',
                      hintStyle: poppins(
                        style: const TextStyle(color: Colors.grey),
                      ),
                      prefixIcon: const Icon(UiconsRegular.search, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _currentFilters.searchQuery = null;
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentFilters.searchQuery =
                            value.isNotEmpty ? value : null;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Add sorting section
                  Text(
                    'Sort By',
                    style: poppins(
                        style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<SortOption>(
                        isExpanded: true,
                        value: _currentFilters.sortBy,
                        items: SortOption.values.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(getSortOptionName(option),
                                style: poppins()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
														print("Selected sort option: $value");
                            setState(() {
                              _currentFilters.sortBy = value;
                            });
														print("Current sort option: ${_currentFilters.sortBy}");
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Time sliders section
                  Text(
                    'Preparation Time',
                    style: poppins(
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          activeColor: mainPurple,
                          value: _currentFilters.maxPrepTime?.toDouble() ?? 240,
                          min: 0,
                          max: 240,
                          divisions: 24,
                          onChanged: (value) {
                            setState(() {
                              _currentFilters.maxPrepTime = value.toInt();
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text(
                          _currentFilters.maxPrepTime != null
                              ? '${_currentFilters.maxPrepTime} min'
                              : 'Any',
                          style: poppins(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(UiconsRegular.cross, size: 10),
                        onPressed: () {
                          setState(() {
                            _currentFilters.maxPrepTime = null;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Cooking Time',
                    style: poppins(
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          activeColor: mainPurple,
                          value: _currentFilters.maxCookTime?.toDouble() ?? 120,
                          min: 0,
                          max: 120,
                          divisions: 12,
                          onChanged: (value) {
                            setState(() {
                              _currentFilters.maxCookTime = value.toInt();
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text(
                          _currentFilters.maxCookTime != null
                              ? '${_currentFilters.maxCookTime} min'
                              : 'Any',
                          style: poppins(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(UiconsRegular.cross, size: 10),
                        onPressed: () {
                          setState(() {
                            _currentFilters.maxCookTime = null;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tags section
                  Text(
                    'Tags',
                    style: poppins(
                        style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    )),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: widget.availableTags.map((tag) {
                      final isSelected =
                          _currentFilters.selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag, style: poppins()),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _currentFilters.selectedTags.add(tag);
                            } else {
                              _currentFilters.selectedTags.remove(tag);
                            }
                          });
                        },
                        backgroundColor: Colors.grey.shade200,
                        selectedColor: lighterPurple.withOpacity(0.5),
                        checkmarkColor: mainPurple,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Bottom action buttons
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentFilters.reset();
                        _searchController.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: mainPurple),
                    ),
                    child: Text('Reset',
                        style:
                            poppins(style: const TextStyle(color: mainPurple))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onFiltersChanged(_currentFilters);
                        widget.onApply();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Apply Filters', style: poppins()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
