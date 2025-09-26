import 'package:budgetbuddy_project/services/local_storage_service.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';
import 'package:budgetbuddy_project/services/transaction_services.dart';
import 'package:budgetbuddy_project/services/balance_service.dart';
import 'package:budgetbuddy_project/models/transaction_model.dart';
import 'package:budgetbuddy_project/common/string_helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
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
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final TransactionServices _transactionServices = locator<TransactionServices>();
  final BalanceService _balanceService = locator<BalanceService>();

  List<String> categories = ['All', 'School', 'Motorcycle', 'Computer'];
  int selectedCategory = 0;
  
  // Time period selection
  String selectedPeriod = 'Week';
  final List<String> periods = ['Week', 'Month', '3 Months'];

  // Analytics data
  List<double> chartData = [];
  List<String> chartLabels = [];
  List<String> chartDates = [];
  double totalIncome = 0;
  double totalExpenses = 0;
  double averageDaily = 0;
  double budgetProgress = 0;
  String budgetStatus = 'On Track';
  Color budgetStatusColor = Colors.green;
  
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
    }
  }

  Future<void> _refreshAnalytics() async {
    final now = DateTime.now();
    final transactions = await _getAllTransactionsForPeriod();
    
    // Filter by category if not "All"
    List<TransactionModel> filteredTransactions = transactions;
    if (selectedCategory > 0) {
      final categoryName = categories[selectedCategory];
      filteredTransactions = transactions
          .where((tx) => tx.category == categoryName)
          .toList();
    }

    // Generate chart data based on selected period
    if (selectedPeriod == 'Week') {
      _generateWeeklyData(filteredTransactions, now);
    } else if (selectedPeriod == 'Month') {
      _generateMonthlyData(filteredTransactions, now);
    } else {
      _generateQuarterlyData(filteredTransactions, now);
    }

    // Calculate summary statistics
    _calculateSummaryStats(filteredTransactions);
    
    setState(() {});
  }

  Future<List<TransactionModel>> _getAllTransactionsForPeriod() async {
    final allTransactions = <TransactionModel>[];
    final categories = _localStorageService.getCategories() ?? ['School', 'Motorcycle', 'Computer'];
    
    for (final category in categories) {
      final categoryTransactions = await _transactionServices.getTransactionByCategory(category);
      allTransactions.addAll(categoryTransactions);
    }
    
    // Filter by date range based on selected period
    final now = DateTime.now();
    DateTime startDate;
    
    switch (selectedPeriod) {
      case 'Week':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case '3 Months':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      default:
        startDate = now.subtract(Duration(days: 7));
    }
    
    return allTransactions
        .where((tx) => tx.date.isAfter(startDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void _generateWeeklyData(List<TransactionModel> transactions, DateTime now) {
    chartData = List.filled(7, 0.0);
    chartLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    chartDates = [];
    
    // Generate dates for the past week
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      chartDates.add('${_monthName(date.month)} ${date.day}, ${date.year}');
    }
    
    // Aggregate transactions by day
    for (final transaction in transactions) {
      final daysAgo = now.difference(transaction.date).inDays;
      if (daysAgo >= 0 && daysAgo < 7) {
        final index = 6 - daysAgo;
        chartData[index] += transaction.amount.abs(); // Use absolute value for expenses
      }
    }
  }

  void _generateMonthlyData(List<TransactionModel> transactions, DateTime now) {
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    chartData = List.filled(daysInMonth, 0.0);
    chartLabels = [];
    chartDates = [];
    
    // Generate labels and dates for the month
    for (int day = 1; day <= daysInMonth; day++) {
      chartLabels.add(day.toString());
      final date = DateTime(now.year, now.month, day);
      chartDates.add('${_monthName(date.month)} ${date.day}, ${date.year}');
    }
    
    // Aggregate transactions by day
    for (final transaction in transactions) {
      if (transaction.date.month == now.month && transaction.date.year == now.year) {
        final dayIndex = transaction.date.day - 1;
        if (dayIndex >= 0 && dayIndex < chartData.length) {
          chartData[dayIndex] += transaction.amount.abs();
        }
      }
    }
  }

  void _generateQuarterlyData(List<TransactionModel> transactions, DateTime now) {
    chartData = List.filled(12, 0.0); // 12 weeks
    chartLabels = [];
    chartDates = [];
    
    // Generate weekly labels for the past 3 months
    for (int week = 11; week >= 0; week--) {
      final weekStart = now.subtract(Duration(days: week * 7));
      chartLabels.add('W${12 - week}');
      chartDates.add('Week of ${_monthName(weekStart.month)} ${weekStart.day}');
    }
    
    // Aggregate transactions by week
    for (final transaction in transactions) {
      final weeksAgo = now.difference(transaction.date).inDays ~/ 7;
      if (weeksAgo >= 0 && weeksAgo < 12) {
        final index = 11 - weeksAgo;
        chartData[index] += transaction.amount.abs();
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
    
    // Calculate average daily spending
    final days = selectedPeriod == 'Week' ? 7 : (selectedPeriod == 'Month' ? 30 : 90);
    averageDaily = totalExpenses / days;
    
    // Calculate budget progress (assuming a simple budget of current balance + total expenses)
    _calculateBudgetStatus();
  }

  Future<void> _calculateBudgetStatus() async {
    final currentBalance = await _balanceService.getBalance();
    final totalAvailable = currentBalance + totalExpenses;
    
    if (totalAvailable > 0) {
      budgetProgress = (totalExpenses / totalAvailable).clamp(0.0, 1.0);
      
      if (budgetProgress < 0.5) {
        budgetStatus = 'Great! Under Budget';
        budgetStatusColor = Colors.green;
      } else if (budgetProgress < 0.8) {
        budgetStatus = 'On Track';
        budgetStatusColor = Colors.orange;
      } else {
        budgetStatus = 'Over Budget';
        budgetStatusColor = Colors.red;
      }
    } else {
      budgetProgress = 0;
      budgetStatus = 'No Budget Data';
      budgetStatusColor = Colors.grey;
    }
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  double get maxY {
    if (chartData.isEmpty) return 1000;
    final max = chartData.reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble(); // Add 20% padding
  }

  int get highlightIndex {
    if (chartData.isEmpty) return 0;
    double maxValue = chartData[0];
    int maxIndex = 0;
    for (int i = 1; i < chartData.length; i++) {
      if (chartData[i] > maxValue) {
        maxValue = chartData[i];
        maxIndex = i;
      }
    }
    return maxIndex;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Color(0xFFF6F6F6),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selection
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 12, right: 12, bottom: 8),
              child: Row(
                children: [
                  Text(
                    'Time Period: ',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ...periods.map((period) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(period),
                      selected: selectedPeriod == period,
                      selectedColor: Colors.black,
                      backgroundColor: Colors.grey[200],
                      labelStyle: GoogleFonts.inter(
                        color: selectedPeriod == period ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedPeriod = period;
                        });
                        _refreshAnalytics();
                      },
                    ),
                  )),
                ],
              ),
            ),

            // Category Filter
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(categories.length, (index) {
                    bool isSelected = selectedCategory == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          categories[index],
                          style: GoogleFonts.inter(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Colors.black,
                        backgroundColor: Colors.grey[200],
                        onSelected: (_) {
                          setState(() {
                            selectedCategory = index;
                          });
                          _refreshAnalytics();
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }),
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
                          valueColor: AlwaysStoppedAnimation<Color>(budgetStatusColor),
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
                ],
              ),
            ),

            // Graph Card
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
                    '${categories[selectedCategory]} ${selectedPeriod == 'Week' ? 'Daily' : selectedPeriod == 'Month' ? 'Daily' : 'Weekly'} Spending',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getPeriodDateRange(),
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: screenHeight * 0.45,
                    width: double.infinity,
                    child: chartData.isEmpty ? 
                      Center(
                        child: Text(
                          'No data available',
                          style: GoogleFonts.inter(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ) :
                      BarChart(
                        BarChartData(
                          maxY: maxY,
                          minY: 0,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: Colors.black,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final dateText = chartDates.length > group.x ? 
                                    chartDates[group.x] : 'Unknown date';
                                return BarTooltipItem(
                                  '$dateText\n₱${rod.toY.toStringAsFixed(2)}',
                                  GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 50,
                                getTitlesWidget: (value, meta) {
                                  final interval = maxY > 10000 ? 5000 : (maxY > 1000 ? 1000 : 500);
                                  if (value % interval != 0) return Container();
                                  return Text(
                                    '₱${(value ~/ 1000)}K',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  int idx = value.toInt();
                                  if (idx < 0 || idx >= chartLabels.length) {
                                    return Container();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      chartLabels[idx],
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: maxY > 10000 ? 5000 : (maxY > 1000 ? 1000 : 500),
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey[200],
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(chartData.length, (index) {
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: chartData[index],
                                  color: index == highlightIndex
                                      ? Colors.black
                                      : Colors.grey[350],
                                  width: 32,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                  ),
                ],
              ),
            ),

            // Summary Statistics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

            // Additional Insights
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
                          color: (totalIncome - totalExpenses) >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getPeriodDateRange() {
    final now = DateTime.now();
    if (selectedPeriod == 'Week') {
      final weekStart = now.subtract(const Duration(days: 6));
      return '${_monthName(weekStart.month)} ${weekStart.day}, ${weekStart.year} - ${_monthName(now.month)} ${now.day}, ${now.year}';
    } else if (selectedPeriod == 'Month') {
      final monthStart = DateTime(now.year, now.month, 1);
      return '${_monthName(monthStart.month)} ${monthStart.day}, ${monthStart.year} - ${_monthName(now.month)} ${now.day}, ${now.year}';
    } else {
      final quarterStart = DateTime(now.year, now.month - 3, now.day);
      return '${_monthName(quarterStart.month)} ${quarterStart.day}, ${quarterStart.year} - ${_monthName(now.month)} ${now.day}, ${now.year}';
    }
  }
}