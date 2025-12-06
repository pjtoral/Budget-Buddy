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

    double thisWeekTotal = 0;
    double lastWeekTotal = 0;
    double thisMonthTotal = 0;
    double lastMonthTotal = 0;

    for (var tx in transactions) {
      final date = tx.date;
      final amount = tx.amount;

      final currentWeek = DateTime(
        now.year,
        now.month,
        now.day - now.weekday + 1,
      );
      final lastWeekStart = currentWeek.subtract(const Duration(days: 7));
      final lastWeekEnd = currentWeek.subtract(const Duration(days: 1));

      if (date.isAfter(currentWeek.subtract(const Duration(days: 1)))) {
        thisWeekTotal += amount;
      } else if (date.isAfter(
            lastWeekStart.subtract(const Duration(days: 1)),
          ) &&
          date.isBefore(lastWeekEnd.add(const Duration(days: 1)))) {
        lastWeekTotal += amount;
      }

      if (date.year == now.year && date.month == now.month) {
        thisMonthTotal += amount;
      }

      final lastMonth = DateTime(now.year, now.month - 1);
      if (date.year == lastMonth.year && date.month == lastMonth.month) {
        lastMonthTotal += amount;
      }
    }

    setState(() {
      _transactionSummaries = [
        {
          'title': 'This Week',
          'amount': formatMoney(thisWeekTotal),
          'amountColor': thisWeekTotal >= 0 ? Colors.green : Colors.red,
          'subtitle': 'vs last week',
        },
        {
          'title': 'Last Week',
          'amount': formatMoney(lastWeekTotal),
          'amountColor': lastWeekTotal >= 0 ? Colors.green : Colors.red,
          'subtitle': '',
        },
        {
          'title': 'This Month',
          'amount': formatMoney(thisMonthTotal),
          'amountColor': thisMonthTotal >= 0 ? Colors.green : Colors.red,
          'subtitle': 'vs last month',
        },
        {
          'title': 'Last Month',
          'amount': formatMoney(lastMonthTotal),
          'amountColor': lastMonthTotal >= 0 ? Colors.green : Colors.red,
          'subtitle': '',
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

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      chartDates.add('${_monthName(date.month)} ${date.day}, ${date.year}');
    }

    for (final transaction in transactions) {
      // Only count expenses (negative amounts) for spending graph
      if (transaction.amount < 0) {
        final daysAgo = now.difference(transaction.date).inDays;
        if (daysAgo >= 0 && daysAgo < 7) {
          final index = 6 - daysAgo;
          chartData[index] += transaction.amount.abs();
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
              ProfileCard(
                username: _username,
              ),
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
