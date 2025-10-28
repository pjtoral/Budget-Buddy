import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:budgetbuddy_project/common/string_helpers.dart';

/// A stateless widget that displays a horizontal scrollable list of transaction summaries.
///
/// The `TransactionSummaryCard` widget shows key transaction metrics such as
/// total spending, income, or category-specific summaries. Each summary is
/// displayed in a card format with a title, amount, and subtitle.
///
/// The widget includes a "See More" button that navigates to a detailed
/// transactions page. A scrollbar is provided for better navigation through
/// the horizontal list of summaries.
class TransactionSummaryCard extends StatelessWidget {
  /// A callback function invoked when the "See More" button is tapped.
  ///
  /// This typically navigates to a detailed transactions page.
  final VoidCallback onSeeMoreTap;

  /// A list of transaction summary data to display.
  ///
  /// Each map should contain the following keys:
  /// - `'title'`: The title of the summary (e.g., "Total Spending").
  /// - `'amount'`: The formatted amount string (e.g., "₱1,234.56").
  /// - `'amountColor'`: The color to use for the amount text.
  /// - `'subtitle'`: Additional information (e.g., "This month").
  final List<Map<String, dynamic>> transactionSummaries;

  /// Creates a `TransactionSummaryCard` widget.
  ///
  /// The [onSeeMoreTap] and [transactionSummaries] parameters are required
  /// and must not be null.
  const TransactionSummaryCard({
    super.key,
    required this.onSeeMoreTap,
    required this.transactionSummaries,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing.
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Controller for the horizontal scroll view.
    final ScrollController _scrollController = ScrollController();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 0),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with title and "See More" button.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.04,
                ),
              ),
              // "See More" button for navigation to detailed transactions page.
              GestureDetector(
                onTap: onSeeMoreTap,
                child: Text(
                  'See More',
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.015),

          // Scrollbar with horizontal scroll view for transaction summaries.
          Scrollbar(
            controller: _scrollController,
            thumbVisibility: false, // Scrollbar appears only when scrolling
            radius: const Radius.circular(8),
            thickness: 4,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    transactionSummaries.map((summary) {
                      return Container(
                        margin: EdgeInsets.only(right: screenWidth * 0.03),
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.03,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display the summary title.
                            Text(
                              summary['title'],
                              style: GoogleFonts.inter(
                                fontSize: screenWidth * 0.03,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            // Display the amount with color coding.
                            Text(
                              summary['amount'],
                              style: GoogleFonts.inter(
                                color: summary['amountColor'],
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.05,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            // Display the subtitle with additional context.
                            Text(
                              summary['subtitle'],
                              style: GoogleFonts.inter(
                                color: Colors.grey[600],
                                fontSize: screenWidth * 0.027,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
