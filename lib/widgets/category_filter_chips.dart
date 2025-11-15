import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A stateless widget that displays a horizontal scrollable list of category filter chips.
///
/// The `CategoryFilterChips` widget allows users to select a category from a list
/// of available categories. The selected category is visually highlighted with a
/// different color scheme. When a chip is tapped, the `onCategorySelected` callback
/// is invoked with the selected category.
///
/// This widget is useful for filtering content based on categories in a user-friendly
/// and visually appealing manner.
class CategoryFilterChips extends StatelessWidget {
  /// The list of category names to display as filter chips.
  final List<String> categories;

  /// The currently selected category.
  ///
  /// This value is used to determine which chip should be visually highlighted.
  final String selectedCategory;

  /// A callback function that is invoked when a category chip is selected.
  ///
  /// The selected category name is passed as an argument to this function.
  final Function(String) onCategorySelected;

  /// Creates a `CategoryFilterChips` widget.
  ///
  /// The [categories], [selectedCategory], and [onCategorySelected] parameters
  /// are required and must not be null.
  ///
  /// The `key` parameter is optional and can be used to uniquely identify
  /// this widget in the widget tree.
  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // Get the screen width for responsive font sizing.
    final double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      // Enable horizontal scrolling for the category chips.
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children:
            categories.map((cat) {
              // Determine if the current category is selected.
              final bool isSelected = selectedCategory == cat;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  labelPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                  // Display the category name as the chip label.
                  label: Text(
                    cat,
                    style: GoogleFonts.inter(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w500,
                      // Use white text for selected chips, black for unselected.
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  selected: isSelected,
                  // Style the selected chip with a black background.
                  selectedColor: Colors.black,
                  // Style unselected chips with a grey background.
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  // Invoke the callback when a chip is selected.
                  onSelected: (_) => onCategorySelected(cat),
                ),
              );
            }).toList(),
      ),
    );
  }
}
