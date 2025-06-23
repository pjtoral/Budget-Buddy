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
            status: 'Urgent',
            statusColor: Colors.red[50]!,
            labelColor: Colors.red[400]!,
            title: 'Task Overdue!',
            description: 'You have tasks marked as urgent that are overdue.',
          ),
          _notificationCard(
            status: 'In-Progress',
            statusColor: Colors.grey[200]!,
            labelColor: Colors.purple[400]!,
            title: 'Task In Progress',
            description: 'You have tasks currently in progress. Keep it up!',
          ),
          _notificationCard(
            status: 'Completed',
            statusColor: Colors.blue[50]!,
            labelColor: Colors.blue[400]!,
            title: 'All Done!',
            description: 'Great job! You have completed all your tasks.',
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            margin: const EdgeInsets.only(top: 2, left: 12, right: 12, bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              description,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}