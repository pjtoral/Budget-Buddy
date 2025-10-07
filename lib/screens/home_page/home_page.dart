import 'package:budgetbuddy_project/common/string_helpers.dart';
import 'package:budgetbuddy_project/screens/home_page/deduct.dart';
import 'package:budgetbuddy_project/screens/home_page/topup.dart';
import 'package:budgetbuddy_project/services/balance_service.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';
import 'package:budgetbuddy_project/services/transaction_services.dart';
import 'package:budgetbuddy_project/services/local_storage_service.dart';
import 'package:budgetbuddy_project/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onSeeMoreTap;
  final VoidCallback onAnalyticsTap;

  const HomePage({
    super.key,
    required this.onSeeMoreTap,
    required this.onAnalyticsTap,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  final TransactionServices _transactionservices = locator<TransactionServices>();
  double _currentBalanceHome = 0.0;
  List<Map<String, dynamic>> _transactionSummaries = [];

  @override
  bool get wantKeepAlive => false; // Don't keep state alive

  @override
  void initState() {
    super.initState();
    _loadBalance(); // Fixed: Added parentheses
    _loadTransactionSummaries();
  }

  // Add this to reload data when page becomes visible
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshData();
  }

  Future<void> _refreshData() async {
    await _loadBalance();
    await _loadTransactionSummaries();
  }

  Future<void> _loadBalance() async {
    final balanceService = locator<BalanceService>();
    final balance = await balanceService.getBalance();
    setState(() {
      _currentBalanceHome = balance;
    });
  }

  Future<void> _onTopUp(double amount) async {
    await _loadBalance();
    await _loadTransactionSummaries();
  }

  Future<void> _onDeduct(double amount) async {
    await _loadBalance();
    await _loadTransactionSummaries();
  }

  Future<void> _loadTransactionSummaries() async {
    // Get all transactions from all categories
    final allTransactions = <TransactionModel>[];
    final userCategories = locator<LocalStorageService>().getCategories();
    
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

      final currentWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
      final lastWeekStart = currentWeek.subtract(const Duration(days: 7));
      final lastWeekEnd = currentWeek.subtract(const Duration(days: 1));

      // this week
      if (date.isAfter(currentWeek.subtract(const Duration(days: 1)))) {
        thisWeekTotal += amount;
      }
      // last week
      else if (date.isAfter(lastWeekStart.subtract(const Duration(days: 1))) &&
          date.isBefore(lastWeekEnd.add(const Duration(days: 1)))) {
        lastWeekTotal += amount;
      }

      // this month
      if (date.year == now.year && date.month == now.month) {
        thisMonthTotal += amount;
      }

      // last month
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

  // For the graph
  final List<double> amounts = [3000, 4000, 2000, 6000, 2500, 7200, 4500];
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> dates = [
    'June 2, 2025',
    'June 3, 2025',
    'June 4, 2025',
    'June 5, 2025',
    'June 6, 2025',
    'June 7, 2025',
    'June 8, 2025',
  ];

  int highlightIndex = 3;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              Container(
                margin: EdgeInsets.all(screenWidth * 0.04),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  border: Border.all(
                    width: 1.0,
                    color: const Color(0xEEE0E0E0),
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.1),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.07,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: AssetImage('assets/images/alden.jpg'),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, Welcome!',
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            'UserName',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/images/logo.png',
                      height: screenWidth * 0.08,
                      width: screenWidth * 0.08,
                    ),
                  ],
                ),
              ),
              // Balance Card
              FutureBuilder<double>(
                future: locator<BalanceService>().getBalance(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error loading balance'));
                  } else {
                    final balance = snapshot.data ?? 0.0;
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(screenWidth * 0.04),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        border: Border.all(
                          width: 1.0,
                          color: const Color(0xEEE0E0E0),
                        ),
                        borderRadius: BorderRadius.circular(screenWidth * 0.1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Balance',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.012),
                          Text(
                            balance > 10000000
                                ? 'you are too rich for this app </3'
                                : formatMoney(balance),
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: screenWidth * 0.09,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.025),
                          // Add and Deduct Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Add Button
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TopUpPage(
                                          onConfirm: (double amount) async {
                                            await _onTopUp(amount);
                                          },
                                        ),
                                      ),
                                    );
                                    // Refresh data when returning
                                    await _refreshData();
                                  },
                                  child: Container(
                                    height: screenHeight * 0.07,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(
                                        screenHeight * 0.035,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        SizedBox(width: screenWidth * 0.04),
                                        Container(
                                          width: screenWidth * 0.09,
                                          height: screenWidth * 0.09,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.black,
                                            size: screenWidth * 0.06,
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.03),
                                        Text(
                                          'Add',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.045,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.04),
                              // Deduct Button
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DeductPage(
                                          onConfirm: (double amount) async {
                                            await _onDeduct(amount);
                                          },
                                        ),
                                      ),
                                    );
                                    // Refresh data when returning
                                    await _refreshData();
                                  },
                                  child: Container(
                                    height: screenHeight * 0.07,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(
                                        screenHeight * 0.035,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: screenWidth * 0.09,
                                          height: screenWidth * 0.09,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.remove,
                                            color: Colors.black,
                                            size: screenWidth * 0.06,
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.03),
                                        Text(
                                          'Deduct',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.045,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              // Transactions Summary
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: 0,
                ),
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transactions',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onSeeMoreTap,
                          child: Text(
                            'See More',
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _transactionSummaries.map((summary) {
                          return Container(
                            margin: EdgeInsets.only(
                              right: screenWidth * 0.03,
                            ),
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.03,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  summary['title'],
                                  style: GoogleFonts.inter(
                                    fontSize: screenWidth * 0.03,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Text(
                                  summary['amount'],
                                  style: GoogleFonts.inter(
                                    color: summary['amountColor'],
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.05,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Text(
                                  summary['subtitle'],
                                  style: GoogleFonts.inter(
                                    color: Colors.grey[600],
                                    fontSize: screenWidth * 0.027,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              // Graph Card
              Container(
                margin: EdgeInsets.all(screenWidth * 0.04),
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.07),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Graph Report',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onAnalyticsTap,
                          child: Text(
                            'See More',
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      'Overview',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      'June 2, 2025 - June 8, 2025',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: screenWidth * 0.032,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    SizedBox(
                      width: screenWidth * 0.9,
                      child: AspectRatio(
                        aspectRatio: 1.2,
                        child: BarChart(
                          BarChartData(
                            maxY: 8000,
                            minY: 0,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: Colors.black,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    '${dates[group.x]}\n₱${rod.toY.toStringAsFixed(2)}',
                                    GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: screenWidth * 0.1,
                                  getTitlesWidget: (value, meta) {
                                    if (value % 1000 != 0) return Container();
                                    return Text(
                                      '₱${(value ~/ 1000)}K',
                                      style: GoogleFonts.inter(
                                        fontSize: screenWidth * 0.03,
                                        color: Colors.grey[700],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int idx = value.toInt();
                                    if (idx < 0 || idx >= days.length) {
                                      return Container();
                                    }
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        top: screenHeight * 0.007,
                                      ),
                                      child: Text(
                                        days[idx],
                                        style: GoogleFonts.inter(
                                          fontSize: screenWidth * 0.03,
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
                              horizontalInterval: 1000,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.grey[200],
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(amounts.length, (index) {
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: amounts[index],
                                    color: index == highlightIndex
                                        ? Colors.black
                                        : Colors.grey[350],
                                    width: screenWidth * 0.07,
                                    borderRadius: BorderRadius.circular(
                                      screenWidth * 0.015,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}