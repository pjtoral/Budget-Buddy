import 'package:flutter/material.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';
import 'package:budgetbuddy_project/services/local_storage_service.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Color(0xFFF7F7F7),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              padding: const EdgeInsets.all(20),
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
                  Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  _faqItem(
                    question: 'How do I add a new task?',
                    answer:
                        'Tap the "+" button on the home screen to add a new task.',
                  ),
                  _faqItem(
                    question: 'How do I mark a task as completed?',
                    answer:
                        'Change its status to "Completed" from the task card.',
                  ),
                  _faqItem(
                    question: 'Can I edit or delete a task?',
                    answer: 'Yes, tap on a task to edit or remove it.',
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Contact Support',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'For further assistance, email us at:\n'
                    'support@budgetbuddy.app\n\n'
                    'We are here to help you manage your tasks better!',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            //   child: ElevatedButton.icon(
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.red,
            //       foregroundColor: Colors.white,
            //       minimumSize: Size(double.infinity, 48),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //     icon: Icon(Icons.delete_forever),
            //     label: Text('Reset Local Storage'),
            //     onPressed: () async {
            //       await locator<LocalStorageService>().clearAll();
            //       if (context.mounted) {
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           SnackBar(content: Text('Local storage cleared!')),
            //         );
            //       }
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _faqItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(answer, style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
