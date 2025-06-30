import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('What is Budget Buddy?'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF7F7F7),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(Icons.account_balance_wallet_rounded, size: 56, color: Colors.black87),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Budget Buddy',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Budget Buddy is your simple, modern, and user-friendly finance tracker. '
                    'Easily manage your income and expenses, track your spending habits, and visualize your financial health—all in one place.',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Key Features',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  _featureItem('• Instantly see your current balance and recent transactions.'),
                  _featureItem('• Add income or expenses with a single tap.'),
                  _featureItem('• Categorize your spending for better insights.'),
                  _featureItem('• Visualize your financial trends with clear, simple graphs.'),
                  _featureItem('• Clean, distraction-free interface for easy navigation.'),
                  SizedBox(height: 20),
                  Text(
                    'How to Use',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  _featureItem('1. Tap "Top Up" to add income or "Deduct" to record expenses.'),
                  _featureItem('2. View your transaction history and reports in the Graph Report tab.'),
                  _featureItem('3. Manage your profile and settings from the account tab.'),
                  SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Budget Buddy helps you take control of your finances—simply and effectively.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
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

  Widget _featureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 15, color: Colors.black87),
      ),
    );
  }
}