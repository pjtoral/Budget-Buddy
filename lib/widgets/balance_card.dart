import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:budgetbuddy_project/common/string_helpers.dart';
import 'package:budgetbuddy_project/services/balance_service.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<double>(
      future: locator<BalanceService>().getBalance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading balance'));
        } else {
          final balance = snapshot.data ?? 0.0;
          return Container(
            width: double.infinity,
            margin: EdgeInsets.all(screenWidth * 0.04),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.02,
            ),
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              border: Border.all(width: 1.0, color: const Color(0xEEE0E0E0)),
              borderRadius: BorderRadius.circular(screenWidth * 0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Balance',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
                SizedBox(height: screenHeight * 0.012),
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
