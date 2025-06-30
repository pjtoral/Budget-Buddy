import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          'Analytics Page',
          style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
