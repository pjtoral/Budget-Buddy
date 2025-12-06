import 'package:budgetbuddy_project/services/local_storage_service.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';
import 'package:budgetbuddy_project/services/transaction_services.dart';
import 'package:budgetbuddy_project/services/balance_service.dart';
import 'package:budgetbuddy_project/models/transaction_model.dart';
import 'package:budgetbuddy_project/common/string_helpers.dart';
import 'package:budgetbuddy_project/widgets/graph_report_card.dart';
import 'package:budgetbuddy_project/widgets/category_filter_chips.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GraphReportScreen();
  }
}

class GraphReportScreen extends StatefulWidget {
  const GraphReportScreen({super.key});

  @override
  State<GraphReportScreen> createState() => _GraphReportScreenState();
}

class _GraphReportScreenState extends State<GraphReportScreen> {
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();
  final TransactionServices _transactionServices =
      locator<TransactionServices>();
  final BalanceService _balanceService = locator<BalanceService>();

  List<String> categories = ['All'];
  int selectedCategory = 0;

  String selectedPeriod = 'Week';
  final List<String> periods = ['Week', 'Month'];

  List<double> chartData = [];
  List<String> chartLabels = [];
  List<String> chartDates = [];
  double totalIncome = 0;
  double totalExpenses = 0;
  double averageDaily = 0;
  double budgetProgress = 0;
  String budgetStatus = 'On Track';
  Color budgetStatusColor = Colors.green;
  String budgetExplanation = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadCategories();
    await _refreshAnalytics();
  }

  Future<void> _loadCategories() async {
    final cats = _localStorageService.getCategories();
    if (cats != null && cats.isNotEmpty) {
      setState(() {
        categories = ['All', ...cats];
        if (selectedCategory >= categories.length) {
          selectedCategory = 0;
        }
      });
    } else {
      setState(() {
        categories = ['All'];
        selectedCategory = 0;
      });
    }
  }

  Future<void> _refreshAnalytics() async {
    final now = DateTime.now();
    final transactions = await _getAllTransactionsForPeriod();

    List<TransactionModel> filteredTransactions = transactions;
    if (selectedCategory > 0 && selectedCategory < categories.length) {
      final categoryName = categories[selectedCategory];
      filteredTransactions =
          transactions.where((tx) => tx.category == categoryName).toList();
    }

    if (selectedPeriod == 'Week') {
      _generateWeeklyData(filteredTransactions, now);
    } else if (selectedPeriod == 'Month') {
      _generateMonthlyData(filteredTransactions, now);
    }

    _calculateSummaryStats(filteredTransactions);
    setState(() {});
  }

  Future<List<TransactionModel>> _getAllTransactionsForPeriod() async {
    final allTransactions = <TransactionModel>[];
    final userCategories = _localStorageService.getCategories();

    if (userCategories != null && userCategories.isNotEmpty) {
      for (final category in userCategories) {
        final categoryTransactions = await _transactionServices
            .getTransactionByCategory(category);
        allTransactions.addAll(categoryTransactions);
      }
    }

    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (selectedPeriod) {
      case 'Week':
        startDate = now.subtract(const Duration(days: 7));
        endDate = now.add(const Duration(days: 1));
        break;
      case 'Month':
        // Get transactions from 3 months ago to 3 months ahead
        startDate = DateTime(now.year, now.month - 3, 1);
        endDate = DateTime(
          now.year,
          now.month + 4,
          0,
        ); // Last day of 3 months ahead
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
        endDate = now.add(const Duration(days: 1));
    }

    return allTransactions
        .where(
          (tx) =>
              tx.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              tx.date.isBefore(endDate),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void _generateWeeklyData(List<TransactionModel> transactions, DateTime now) {
    chartData = List.filled(7, 0.0);
    chartLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    chartDates = [];

    // Calculate the start of the week (Monday)
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
  }

  void _generateMonthlyData(List<TransactionModel> transactions, DateTime now) {
    // Show last 3 months, current month, and next 3 months (7 months total)
    chartData = List.filled(7, 0.0);
    chartLabels = [];
    chartDates = [];

    // Generate labels for 7 months: 3 past, current, 3 future
    for (int i = -3; i <= 3; i++) {
      final targetDate = DateTime(now.year, now.month + i, 1);
      chartLabels.add(
        _monthName(targetDate.month).substring(0, 3),
      ); // Short month name
      chartDates.add('${_monthName(targetDate.month)} ${targetDate.year}');
    }

    // Aggregate transactions by month
    for (final transaction in transactions) {
      // Only count expenses (negative amounts) for spending graph
      if (transaction.amount < 0) {
        final txDate = transaction.date;
        final monthsDiff =
            (now.year - txDate.year) * 12 + (now.month - txDate.month);

        // Check if transaction is within the 7-month range (-3 to +3)
        if (monthsDiff >= -3 && monthsDiff <= 3) {
          final index = monthsDiff + 3; // Convert -3..3 to 0..6
          if (index >= 0 && index < chartData.length) {
            chartData[index] += transaction.amount.abs();
          }
        }
      }
    }
  }

  void _calculateSummaryStats(List<TransactionModel> transactions) {
    totalIncome = 0;
    totalExpenses = 0;

    for (final transaction in transactions) {
      if (transaction.amount > 0) {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += transaction.amount.abs();
      }
    }

    final days = selectedPeriod == 'Week' ? 7 : 30;
    averageDaily = totalExpenses / days;

    _calculateBudgetStatus();
  }

  Future<void> _calculateBudgetStatus() async {
    final currentBalance = await _balanceService.getBalance();

    // If there's income in this period, compare expenses to income
    if (totalIncome > 0) {
      budgetProgress = (totalExpenses / totalIncome).clamp(0.0, 1.0);

      if (budgetProgress < 0.5) {
        budgetStatus = 'Great! Under Budget';
        budgetStatusColor = Colors.green;
        budgetExplanation =
            'You\'ve spent less than 50% of your income. Excellent financial management!';
      } else if (budgetProgress < 0.8) {
        budgetStatus = 'On Track';
        budgetStatusColor = Colors.orange;
        budgetExplanation =
            'You\'ve spent ${(budgetProgress * 100).toInt()}% of your income. Keep monitoring your spending.';
      } else if (budgetProgress < 1.0) {
        budgetStatus = 'Approaching Limit';
        budgetStatusColor = Colors.orange;
        budgetExplanation =
            'You\'ve spent ${(budgetProgress * 100).toInt()}% of your income. Consider reducing expenses.';
      } else {
        budgetStatus = 'Over Budget';
        budgetStatusColor = Colors.red;
        budgetExplanation =
            'Your expenses exceed your income by ${formatMoney((totalExpenses - totalIncome))}. Review your spending.';
      }
    } else if (totalExpenses > 0 && currentBalance > 0) {
      // If no income but there are expenses, show spending sustainability
      // Calculate how many days balance would last at current spending rate
      final days = selectedPeriod == 'Week' ? 7 : 30;
      final dailySpending = totalExpenses / days;
      final daysRemaining =
          dailySpending > 0 ? (currentBalance / dailySpending) : 0;

      if (daysRemaining > 30) {
        budgetStatus = 'Spending Sustainable';
        budgetStatusColor = Colors.green;
        budgetProgress = 0.3;
        budgetExplanation =
            'At your current spending rate, your balance will last ${daysRemaining.toInt()} days.';
      } else if (daysRemaining > 14) {
        budgetStatus = 'Monitor Spending';
        budgetStatusColor = Colors.orange;
        budgetProgress = 0.6;
        budgetExplanation =
            'At your current spending rate, your balance will last ${daysRemaining.toInt()} days. Consider adding income.';
      } else {
        budgetStatus = 'Low Balance Warning';
        budgetStatusColor = Colors.red;
        budgetProgress = 0.9;
        budgetExplanation =
            'At your current spending rate, your balance will last ${daysRemaining.toInt()} days. Add income soon.';
      }
    } else if (totalExpenses == 0 && totalIncome == 0) {
      budgetProgress = 0;
      budgetStatus = 'No Transactions';
      budgetStatusColor = Colors.grey;
      budgetExplanation =
          'No transactions recorded for this period. Start tracking your finances!';
    } else {
      budgetProgress = 0;
      budgetStatus = 'No Budget Data';
      budgetStatusColor = Colors.grey;
      budgetExplanation = 'Unable to calculate budget status.';
    }
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
    if (selectedPeriod == 'Week') {
      final weekStart = now.subtract(const Duration(days: 6));
      return '${_monthName(weekStart.month)} ${weekStart.day}, ${weekStart.year} - ${_monthName(now.month)} ${now.day}, ${now.year}';
    } else if (selectedPeriod == 'Month') {
      // Show range for last 3 months to next 3 months
      final startDate = DateTime(now.year, now.month - 3, 1);
      final endDate = DateTime(now.year, now.month + 3, 1);
      return '${_monthName(startDate.month)} ${startDate.year} - ${_monthName(endDate.month)} ${endDate.year}';
    } else {
      final quarterStart = DateTime(now.year, now.month - 3, now.day);
      return '${_monthName(quarterStart.month)} ${quarterStart.day}, ${quarterStart.year} - ${_monthName(now.month)} ${now.day}, ${now.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Budget Analytics',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Sticky header with Period Filter and Category Filter
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              child: Container(
                color: const Color(0xFFF6F6F6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Filter
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 12,
                        left: 12,
                        right: 12,
                        bottom: 6,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Time Period: ',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    periods.map((period) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: ChoiceChip(
                                          label: Text(period),
                                          selected: selectedPeriod == period,
                                          selectedColor: Colors.black,
                                          backgroundColor: Colors.grey[200],
                                          labelStyle: GoogleFonts.inter(
                                            color:
                                                selectedPeriod == period
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          onSelected: (_) {
                                            setState(() {
                                              selectedPeriod = period;
                                            });
                                            _refreshAnalytics();
                                          },
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Category Filter using reusable widget
                    if (categories.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 12,
                          bottom: 8,
                        ),
                        child: CategoryFilterChips(
                          categories: categories,
                          selectedCategory: categories[selectedCategory],
                          onCategorySelected: (cat) {
                            setState(() {
                              selectedCategory = categories.indexOf(cat);
                            });
                            _refreshAnalytics();
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable content
          SliverList(
            delegate: SliverChildListDelegate([
              if (categories.length == 1)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: 12,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Create categories when adding transactions to see detailed analytics',
                            style: GoogleFonts.inter(
                              color: Colors.blue[700],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Budget Status Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Budget Status',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: budgetProgress,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              budgetStatusColor,
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(budgetProgress * 100).toInt()}%',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: budgetStatusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      budgetStatus,
                      style: GoogleFonts.inter(
                        color: budgetStatusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      budgetExplanation,
                      style: GoogleFonts.inter(
                        color: Colors.grey[700],
                        fontSize: 13,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Main Graph Report
              GraphReportCard(
                categoryName: categories[selectedCategory],
                selectedPeriod: selectedPeriod,
                dateRange: _getPeriodDateRange(),
                chartData: chartData,
                chartLabels: chartLabels,
                chartDates: chartDates,
              ),

              // Income & Expense Cards
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Income',
                              style: GoogleFonts.inter(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            AutoSizeText(
                              formatMoney(totalIncome),
                              maxLines: 1,
                              style: GoogleFonts.inter(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Expenses',
                              style: GoogleFonts.inter(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            AutoSizeText(
                              formatMoney(totalExpenses),
                              maxLines: 1,
                              style: GoogleFonts.inter(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Spending Insights
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending Insights',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Average Daily Spending:',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                        Text(
                          formatMoney(averageDaily),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Net Balance Change:',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                        Text(
                          formatMoney(totalIncome - totalExpenses),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color:
                                (totalIncome - totalExpenses) >= 0
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }
}

// Delegate class for sticky header
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 140;

  @override
  double get maxExtent => 150;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
