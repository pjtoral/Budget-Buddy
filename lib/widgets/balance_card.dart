import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:budgetbuddy_project/common/string_helpers.dart';
import 'package:budgetbuddy_project/services/balance_service.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';

/// A stateless widget that displays the user's current balance in a styled card.
///
/// The `BalanceCard` widget fetches the balance asynchronously using the
/// `BalanceService` and displays it in a card with a formatted monetary value.
/// If the balance exceeds a certain threshold, a custom message is displayed.
///
/// This widget uses the `FutureBuilder` to handle the asynchronous nature of
/// fetching the balance and provides appropriate UI feedback for loading and
/// error states.
class BalanceCard extends StatelessWidget {
  /// Creates a `BalanceCard` widget.
  ///
  /// The `key` parameter is optional and can be used to uniquely identify
  /// this widget in the widget tree.
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height for responsive design.
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<double>(
      // Fetch the user's balance using the BalanceService.
      future: locator<BalanceService>().getBalance(),
      builder: (context, snapshot) {
        // Display a loading indicator while the balance is being fetched.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        // Display an error message if there was an issue fetching the balance.
        else if (snapshot.hasError) {
          return Center(child: Text('Error loading balance'));
        }
        // Display the balance once it has been successfully fetched.
        else {
          final balance = snapshot.data ?? 0.0;
          return Container(
            // Set the container to take up the full width of its parent.
            width: double.infinity,
            // Add margin and padding for spacing and layout.
            margin: EdgeInsets.all(screenWidth * 0.04),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.02,
            ),
            // Style the container with a white background, border, and rounded corners.
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              border: Border.all(width: 1.0, color: const Color(0xEEE0E0E0)),
              borderRadius: BorderRadius.circular(screenWidth * 0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the "Current Balance" label.
                Text(
                  'Current Balance',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
                SizedBox(height: screenHeight * 0.012),
                // Display the formatted balance or a custom message if the balance is too high.
                Text(
                  balance > 10000000
                      ? 'you are too rich for this app </3'
                      : formatMoney(balance),
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: screenWidth * 0.09,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
