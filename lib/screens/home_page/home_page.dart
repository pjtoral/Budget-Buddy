import 'package:budgetbuddy_project/common/app_strings.dart';
import 'package:budgetbuddy_project/common/string_helpers.dart';
import 'package:budgetbuddy_project/screens/home_page/deduct.dart';
import 'package:budgetbuddy_project/screens/home_page/topup.dart';
import 'package:budgetbuddy_project/screens/transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double currentBalanceHome = 0.0;
  @override
  void initState() {
    super.initState();
    currentBalanceHome = currentBalance;
  }

  void updateBalance() {
    setState(() {
      currentBalanceHome = currentBalance;
    });
  }

  final List<Map<String, dynamic>> transactionSummaries = [
    {
      'title': 'This Week',
      'amount': '+₱5,433.52',
      'amountColor': Colors.green,
      'subtitle': '+20% month over month',
    },
    {
      'title': 'Last Week',
      'amount': '-₱2,409',
      'amountColor': Colors.red,
      'subtitle': '+33% month over month',
    },
    {
      'title': 'This Month',
      'amount': '+₱12,000.00',
      'amountColor': Colors.green,
      'subtitle': '+10% month over month',
    },
    {
      'title': 'Last Month',
      'amount': '-₱8,500.00',
      'amountColor': Colors.red,
      'subtitle': '+5% month over month',
    },
  ];

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

  int highlightIndex = 3; // Thursday

  @override
  Widget build(BuildContext context) {
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
              Container(
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
                      currentBalanceHome > 10000000
                          ? 'you are too rich for this app </3'
                          : formatMoney(currentBalanceHome),
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: screenWidth * 0.09,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    //Add and Deduct Buttons
                    Row(
                      children: [
                        // Add Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          TopUpPage(onConfirm: updateBalance),
                                ),
                              );
                            },
                            child: Container(
                              height: screenHeight * 0.07,
                              margin: EdgeInsets.only(
                                right: screenWidth * 0.02,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(
                                  screenHeight * 0.035,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: screenWidth * 0.045),
                                  Container(
                                    width: screenWidth * 0.09,
                                    height: screenWidth * 0.09,
                                    decoration: BoxDecoration(
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          DeductPage(onConfirm: updateBalance),
                                ),
                              );
                            },
                            child: Container(
                              height: screenHeight * 0.07,
                              margin: EdgeInsets.only(left: screenWidth * 0.02),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(
                                  screenHeight * 0.035,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: screenWidth * 0.045),
                                  Container(
                                    width: screenWidth * 0.09,
                                    height: screenWidth * 0.09,
                                    decoration: BoxDecoration(
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
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => HomePage(),
                            //   ),
                            // );
                          },
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
                        children:
                            transactionSummaries.map((summary) {
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
              //Graph Card
              Container(
                margin: EdgeInsets.all(screenWidth * 0.04),
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.07),
                  border: Border.all(color: Color(0xFFE0E0E0)),
                ),
                child: Column(
                  children: [
                    // Top Row
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
                        Text(
                          'See More',
                          style: GoogleFonts.inter(
                            color: Colors.grey[600],
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    // Overview Title
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
                    // Bar Chart
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
                                getTooltipItem: (
                                  group,
                                  groupIndex,
                                  rod,
                                  rodIndex,
                                ) {
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
                                    if (idx < 0 || idx >= days.length)
                                      return Container();
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
                              getDrawingHorizontalLine:
                                  (value) => FlLine(
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
                                    color:
                                        index == highlightIndex
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
              // --- End Graph Card ---
            ],
          ),
        ),
      ),
    );
  }
}
