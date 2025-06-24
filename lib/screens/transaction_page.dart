import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          'Transactions Page',
          style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
