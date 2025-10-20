import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:budgetbuddy_project/common/string_helpers.dart';

class TransactionSummaryCard extends StatelessWidget {
  final VoidCallback onSeeMoreTap;
  final List<Map<String, dynamic>> transactionSummaries;

  const TransactionSummaryCard({
    super.key,
    required this.onSeeMoreTap,
    required this.transactionSummaries,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ✅ Controller for the horizontal scroll
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
          // Title + See More
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

          // ✅ Scrollbar + Horizontal Scroll View
          Scrollbar(
            controller: _scrollController,
            thumbVisibility: false, // dipako sure
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
                            Text(
                              summary['title'],
                              style: GoogleFonts.inter(
                                fontSize: screenWidth * 0.03,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              summary['amount'],
                              style: GoogleFonts.inter(
                                color: summary['amountColor'],
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.05,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
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
