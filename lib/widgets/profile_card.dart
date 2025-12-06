import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:budgetbuddy_project/services/balance_service.dart';
import 'package:budgetbuddy_project/services/transaction_services.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';
import 'package:budgetbuddy_project/common/string_helpers.dart';
import 'package:budgetbuddy_project/screens/profile_page/notification.dart';

/// A widget that displays a user profile card with username.
///
/// The `ProfileCard` widget shows a greeting message, username, and the app logo.
/// The logo functions as a notifications button with a badge indicator.
/// It is typically displayed at the top of the home page to provide a personalized
/// welcome experience.
///
/// The card uses responsive sizing based on screen dimensions to ensure proper
/// display across different device sizes.
class ProfileCard extends StatefulWidget {
  /// The username to display on the profile card.
  final String username;

  /// Creates a `ProfileCard` widget.
  ///
  /// The [username] parameter is required and must not be null.
  const ProfileCard({super.key, required this.username});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  final BalanceService _balanceService = locator<BalanceService>();
  final TransactionServices _transactionServices =
      locator<TransactionServices>();

  Map<String, dynamic>? _mostRecentNotification;
  bool _hasNotification = false;

  @override
  void initState() {
    super.initState();
    _loadMostRecentNotification();
  }

  Future<void> _loadMostRecentNotification() async {
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

      double thisMonth = 0.0;
      double lastMonth = 0.0;

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
        }
      }

      // Generate notifications (same logic as NotificationsPage)
      final notifications = <Map<String, dynamic>>[];

      // Low balance alert (highest priority)
      if (balance < 500) {
        notifications.add({
          'status': 'Alert',
          'statusColor': Colors.red[50]!,
          'labelColor': Colors.red[400]!,
          'title': 'Low Balance',
          'description':
              'Your balance is ${formatMoney(balance)}, which is below ₱500. Consider topping up to avoid running out of funds.',
        });
      }

      // Budget warning - if spending this month is high
      if (thisMonth > 0) {
        final spendingRatio = lastMonth > 0 ? (thisMonth / lastMonth) : 1.0;

        if (spendingRatio > 1.2 && thisMonth > 1000) {
          notifications.add({
            'status': 'Reminder',
            'statusColor': Colors.yellow[50]!,
            'labelColor': Colors.orange[400]!,
            'title': 'High Spending This Month',
            'description':
                'You\'ve spent ${formatMoney(thisMonth)} this month, which is ${((spendingRatio - 1) * 100).toStringAsFixed(0)}% more than last month. Review your spending to stay on track.',
          });
        } else if (thisMonth > 5000) {
          notifications.add({
            'status': 'Reminder',
            'statusColor': Colors.yellow[50]!,
            'labelColor': Colors.orange[400]!,
            'title': 'Budget Limit Approaching',
            'description':
                'You\'ve spent ${formatMoney(thisMonth)} this month. Review your spending to stay on track.',
          });
        }
      }

      // Get the most recent notification (first in list has highest priority)
      if (mounted) {
        setState(() {
          _mostRecentNotification =
              notifications.isNotEmpty ? notifications[0] : null;
          _hasNotification = notifications.isNotEmpty;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _showMostRecentNotification() {
    if (_mostRecentNotification == null) {
      // Navigate to notifications page if no notification
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationsPage()),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _mostRecentNotification!['labelColor'] as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _mostRecentNotification!['status'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _mostRecentNotification!['title'] as String,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _mostRecentNotification!['description'] as String,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.inter(color: Colors.grey[700]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('View All', style: GoogleFonts.inter()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing.
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      // Add margin and padding for spacing.
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.015,
      ),
      // Style the card with a white background, border, and rounded corners.
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(screenWidth * 0.1),
      ),
      child: Row(
        children: [
          // Display the greeting and username.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting message.
                Text(
                  'Hi, Welcome!',
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
                // Username display.
                Text(
                  widget.username,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Display the app logo as a notification button with badge.
          GestureDetector(
            onTap: _showMostRecentNotification,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: screenWidth * 0.08,
                  width: screenWidth * 0.08,
                ),
                // Red notification badge
                if (_hasNotification)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: screenWidth * 0.025,
                      height: screenWidth * 0.025,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
