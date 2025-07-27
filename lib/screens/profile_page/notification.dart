import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF7F7F7),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        children: [
          _notificationCard(
            status: 'Update',
            statusColor: Colors.blue[50]!,
            labelColor: Colors.blue[400]!,
            title: 'Version 1.2.0 Released!',
            description:
                'Check out the new Analytics page and improved category management. Update now for the best experience!',
          ),
          _notificationCard(
            status: 'Reminder',
            statusColor: Colors.yellow[50]!,
            labelColor: Colors.orange[400]!,
            title: 'Budget Limit Approaching',
            description:
                'You are close to reaching your monthly budget. Review your spending to stay on track.',
          ),
          _notificationCard(
            status: 'Alert',
            statusColor: Colors.red[50]!,
            labelColor: Colors.red[400]!,
            title: 'Low Balance',
            description:
                'Your balance is below ₱500. Consider topping up to avoid running out of funds.',
          ),
          _notificationCard(
            status: 'Feature',
            statusColor: Colors.green[50]!,
            labelColor: Colors.green[400]!,
            title: 'New: Category Customization',
            description:
                'You can now add, edit, and remove spending categories. Try it out in the Top Up or Deduct pages!',
          ),
          _notificationCard(
            status: 'Promo',
            statusColor: Colors.purple[50]!,
            labelColor: Colors.purple[400]!,
            title: 'Refer & Earn',
            description:
                'Invite friends to BudgetBuddy and earn bonus credits for every successful referral!',
          ),
          _adCard(
            imageUrl:
                'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80',
            title: 'Upgrade to BudgetBuddy Pro!',
            description:
                'Unlock advanced analytics, unlimited categories, and priority support. Try Pro free for 7 days!',
          ),
        ],
      ),
    );
  }

  // Notification Card Widget
  Widget _notificationCard({
    required String status,
    required Color statusColor,
    required Color labelColor,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: labelColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            margin: const EdgeInsets.only(
              top: 2,
              left: 12,
              right: 12,
              bottom: 12,
            ),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              description,
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Simple Ad/Promo Card Widget
  Widget _adCard({
    required String imageUrl,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.network(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
