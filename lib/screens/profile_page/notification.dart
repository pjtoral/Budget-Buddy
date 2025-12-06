import 'package:flutter/material.dart';
import 'package:budgetbuddy_project/services/balance_service.dart';
import 'package:budgetbuddy_project/services/transaction_services.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';
import 'package:budgetbuddy_project/common/string_helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final BalanceService _balanceService = locator<BalanceService>();
  final TransactionServices _transactionServices =
      locator<TransactionServices>();

  double _balance = 0.0;
  double _thisMonthSpending = 0.0;
  double _lastMonthSpending = 0.0;
  double _thisWeekSpending = 0.0;
  int _totalTransactions = 0;
  String _username = 'User';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load balance
      final balance = await _balanceService.getBalance();

      // Load transactions
      final allTransactions = await _transactionServices.getAllTransactions();

      // Calculate spending
      final now = DateTime.now();
      final thisMonthStart = DateTime(now.year, now.month, 1);
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      final lastMonthEnd = DateTime(now.year, now.month, 0);
      final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));

      double thisMonth = 0.0;
      double lastMonth = 0.0;
      double thisWeek = 0.0;

      for (var tx in allTransactions) {
        final amount = tx.amount.abs();
        if (tx.amount < 0) {
          // Only count expenses
          if (tx.date.isAfter(
            thisMonthStart.subtract(const Duration(days: 1)),
          )) {
            thisMonth += amount;
          }
          if (tx.date.isAfter(
                lastMonthStart.subtract(const Duration(days: 1)),
              ) &&
              tx.date.isBefore(lastMonthEnd.add(const Duration(days: 1)))) {
            lastMonth += amount;
          }
          if (tx.date.isAfter(
            thisWeekStart.subtract(const Duration(days: 1)),
          )) {
            thisWeek += amount;
          }
        }
      }

      // Load username
      final user = FirebaseAuth.instance.currentUser;
      String username = 'User';
      if (user != null) {
        try {
          final userDoc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get();
          if (userDoc.exists) {
            username =
                userDoc.data()?['username'] ??
                user.displayName ??
                user.email?.split('@')[0] ??
                'User';
          } else {
            username = user.displayName ?? user.email?.split('@')[0] ?? 'User';
          }
        } catch (e) {
          username = user.displayName ?? user.email?.split('@')[0] ?? 'User';
        }
      }

      if (mounted) {
        setState(() {
          _balance = balance;
          _thisMonthSpending = thisMonth;
          _lastMonthSpending = lastMonth;
          _thisWeekSpending = thisWeek;
          _totalTransactions = allTransactions.length;
          _username = username;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _generateNotifications() {
    final notifications = <Map<String, dynamic>>[];

    // Welcome message for new users
    if (_totalTransactions == 0) {
      notifications.add({
        'status': 'Welcome',
        'statusColor': Colors.blue[50]!,
        'labelColor': Colors.blue[400]!,
        'title': 'Welcome to Budget Buddy, $_username!',
        'description':
            'Start tracking your finances by adding your first transaction. Tap the + button to get started!',
      });
    }

    // Low balance alert
    if (_balance < 500) {
      notifications.add({
        'status': 'Alert',
        'statusColor': Colors.red[50]!,
        'labelColor': Colors.red[400]!,
        'title': 'Low Balance',
        'description':
            'Your balance is ${formatMoney(_balance)}, which is below ₱500. Consider topping up to avoid running out of funds.',
      });
    }

    // Budget warning - if spending this month is high
    if (_thisMonthSpending > 0) {
      final spendingRatio =
          _lastMonthSpending > 0
              ? (_thisMonthSpending / _lastMonthSpending)
              : 1.0;

      if (spendingRatio > 1.2 && _thisMonthSpending > 1000) {
        notifications.add({
          'status': 'Reminder',
          'statusColor': Colors.yellow[50]!,
          'labelColor': Colors.orange[400]!,
          'title': 'High Spending This Month',
          'description':
              'You\'ve spent ${formatMoney(_thisMonthSpending)} this month, which is ${((spendingRatio - 1) * 100).toStringAsFixed(0)}% more than last month. Review your spending to stay on track.',
        });
      } else if (_thisMonthSpending > 5000) {
        notifications.add({
          'status': 'Reminder',
          'statusColor': Colors.yellow[50]!,
          'labelColor': Colors.orange[400]!,
          'title': 'Budget Limit Approaching',
          'description':
              'You\'ve spent ${formatMoney(_thisMonthSpending)} this month. Review your spending to stay on track.',
        });
      }
    }

    // Weekly spending summary
    if (_thisWeekSpending > 0) {
      notifications.add({
        'status': 'Summary',
        'statusColor': Colors.purple[50]!,
        'labelColor': Colors.purple[400]!,
        'title': 'This Week\'s Spending',
        'description':
            'You\'ve spent ${formatMoney(_thisWeekSpending)} this week. Keep tracking to manage your budget effectively.',
      });
    }

    // Balance status
    if (_balance >= 500) {
      notifications.add({
        'status': 'Info',
        'statusColor': Colors.green[50]!,
        'labelColor': Colors.green[400]!,
        'title': 'Current Balance',
        'description':
            'Your current balance is ${formatMoney(_balance)}. You\'re doing great!',
      });
    }

    // Transaction count milestone
    if (_totalTransactions > 0 && _totalTransactions % 10 == 0) {
      notifications.add({
        'status': 'Milestone',
        'statusColor': Colors.teal[50]!,
        'labelColor': Colors.teal[400]!,
        'title': 'Transaction Milestone!',
        'description':
            'You\'ve recorded $_totalTransactions transactions! Keep up the great work tracking your finances.',
      });
    }

    // If no notifications, show a general info
    if (notifications.isEmpty) {
      notifications.add({
        'status': 'Info',
        'statusColor': Colors.blue[50]!,
        'labelColor': Colors.blue[400]!,
        'title': 'All Good!',
        'description':
            'You\'re all set! Your balance is ${formatMoney(_balance)} and you have $_totalTransactions transactions recorded.',
      });
    }

    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 20,
                  ),
                  children:
                      _generateNotifications()
                          .map(
                            (notif) => _notificationCard(
                              status: notif['status'] as String,
                              statusColor: notif['statusColor'] as Color,
                              labelColor: notif['labelColor'] as Color,
                              title: notif['title'] as String,
                              description: notif['description'] as String,
                            ),
                          )
                          .toList(),
                ),
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
}
