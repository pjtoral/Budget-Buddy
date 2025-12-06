import 'package:budgetbuddy_project/common/string_helpers.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';
import 'package:budgetbuddy_project/services/transaction_services.dart';
import 'package:budgetbuddy_project/services/local_storage_service.dart';
import 'package:budgetbuddy_project/models/transaction_model.dart';
import 'package:budgetbuddy_project/widgets/profile_card.dart';
import 'package:budgetbuddy_project/widgets/transactions_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:budgetbuddy_project/widgets/balance_card.dart';
import 'package:budgetbuddy_project/widgets/graph_report_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onSeeMoreTap;
  final VoidCallback onAnalyticsTap;
  final VoidCallback? onRefresh;

  const HomePage({
    super.key,
    required this.onSeeMoreTap,
    required this.onAnalyticsTap,
    this.onRefresh,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final TransactionServices _transactionservices =
      locator<TransactionServices>();
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();

  List<Map<String, dynamic>> _transactionSummaries = [];
  String _username = 'UserName'; // Default value

  // Graph data
  List<double> chartData = [];
  List<String> chartLabels = [];
  List<String> chartDates = [];

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _loadTransactionSummaries();
    _loadGraphData();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshData();
  }

  Future<void> _refreshData() async {
    await _loadTransactionSummaries();
    await _loadGraphData();
    await _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          setState(() {
            _username =
                data?['username'] ??
                user.displayName ??
                user.email?.split('@')[0] ??
                'UserName';
          });
        } else {
          // Fallback to displayName or email
          setState(() {
            _username =
                user.displayName ?? user.email?.split('@')[0] ?? 'UserName';
          });
        }
      } catch (e) {
        // Fallback to displayName or email on error
        setState(() {
          _username =
              user.displayName ?? user.email?.split('@')[0] ?? 'UserName';
        });
      }
    }
  }

  Future<void> _loadTransactionSummaries() async {
    final allTransactions = <TransactionModel>[];
    final userCategories = _localStorageService.getCategories();

    if (userCategories != null && userCategories.isNotEmpty) {
      for (final category in userCategories) {
        final categoryTransactions = await _transactionservices
            .getTransactionByCategory(category);
        allTransactions.addAll(categoryTransactions);
      }
    }

    final transactions = allTransactions;
    final now = DateTime.now();

    // Calculate week boundaries
    final currentWeek = DateTime(
      now.year,
      now.month,
      now.day - now.weekday + 1,
    );

    // Calculate month boundaries
    final thisMonthStart = DateTime(now.year, now.month, 1);

    // Separate income and expenses
    double thisWeekExpenses = 0;
    double thisMonthIncome = 0;
    double thisMonthExpenses = 0;

    for (var tx in transactions) {
      final date = tx.date;
      final amount = tx.amount;
      final absAmount = amount.abs();

      // This week calculations
      if (date.isAfter(currentWeek.subtract(const Duration(days: 1)))) {
        if (amount < 0) {
          thisWeekExpenses += absAmount;
        }
      }

      // This month calculations
      if (date.isAfter(thisMonthStart.subtract(const Duration(days: 1))) &&
          date.isBefore(now.add(const Duration(days: 1)))) {
        if (amount > 0) {
          thisMonthIncome += absAmount;
        } else {
          thisMonthExpenses += absAmount;
        }
      }
    }

    setState(() {
      _transactionSummaries = [
        {
          'title': 'Income',
          'amount': formatMoney(thisMonthIncome),
          'amountColor': Colors.green,
        },
        {
          'title': 'Expenses',
          'amount': formatMoney(thisMonthExpenses),
          'amountColor': Colors.red,
        },
        {
          'title': 'This Week',
          'amount': formatMoney(thisWeekExpenses),
          'amountColor': Colors.red,
        },
        {
          'title': 'Net',
          'amount': formatMoney(thisMonthIncome - thisMonthExpenses),
          'amountColor':
              (thisMonthIncome - thisMonthExpenses) >= 0
                  ? Colors.green
                  : Colors.red,
        },
      ];
    });
  }

  Future<void> _loadGraphData() async {
    final allTransactions = <TransactionModel>[];
    final userCategories = _localStorageService.getCategories();

    if (userCategories != null && userCategories.isNotEmpty) {
      for (final category in userCategories) {
        final categoryTransactions = await _transactionservices
            .getTransactionByCategory(category);
        allTransactions.addAll(categoryTransactions);
      }
    }

    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 7));

    final weekTransactions =
        allTransactions.where((tx) => tx.date.isAfter(startDate)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    _generateWeeklyData(weekTransactions, now);
  }

  void _generateWeeklyData(List<TransactionModel> transactions, DateTime now) {
    chartData = List.filled(7, 0.0);
    chartLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    chartDates = [];

    // Calculate the start of the week (Monday) - same logic as analytics page
    final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
    final weekStart = now.subtract(Duration(days: currentWeekday - 1));

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      chartDates.add('${_monthName(date.month)} ${date.day}, ${date.year}');
    }

    for (final transaction in transactions) {
      // Only count expenses (negative amounts) for spending graph
      if (transaction.amount < 0) {
        // Normalize dates to compare only the date part (ignore time)
        final txDate = DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day,
        );
        final weekStartDate = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day,
        );

        // Check if transaction is within this week
        if (txDate.isAfter(weekStartDate.subtract(const Duration(days: 1))) &&
            txDate.isBefore(weekStartDate.add(const Duration(days: 7)))) {
          // Calculate which day of the week (0 = Monday, 6 = Sunday)
          final dayOfWeek = txDate.weekday - 1; // Convert 1-7 to 0-6
          if (dayOfWeek >= 0 && dayOfWeek < 7) {
            chartData[dayOfWeek] += transaction.amount.abs();
          }
        }
      }
    }

    setState(() {});
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }

  String _getPeriodDateRange() {
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 6));
    return '${_monthName(weekStart.month)} ${weekStart.day}, ${weekStart.year} - ${_monthName(now.month)} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              ProfileCard(username: _username),
              // Balance Card
              const BalanceCard(),
              // Transactions Summary Card
              TransactionSummaryCard(
                onSeeMoreTap: widget.onSeeMoreTap,
                transactionSummaries: _transactionSummaries,
              ),
              // Graph Card with real data
              GraphReportCard(
                categoryName: 'All',
                selectedPeriod: 'Week',
                dateRange: _getPeriodDateRange(),
                chartData: chartData,
                chartLabels: chartLabels,
                chartDates: chartDates,
                onAnalyticsTap: widget.onAnalyticsTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
