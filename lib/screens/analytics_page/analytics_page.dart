import 'package:budgetbuddy_project/services/local_storage_service.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';
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
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();

  List<String> categories = [
    'School',
    'Motorcycle',
    'Computer',
  ]; // Changed to non-final
  int selectedCategory = 0; // Changed to 0 (first category)

  // Example data for each category (you can expand this dynamically)
  final Map<String, List<double>> categoryAmounts = {
    'School': [2000, 3000, 2500, 4000, 3500, 4200, 3100],
    'Motorcycle': [3000, 4000, 2000, 6000, 2500, 7200, 4500],
    'Computer': [1000, 2000, 1500, 3000, 2500, 3200, 2100],
  };

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
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = _localStorageService.getCategories();
    if (cats != null && cats.isNotEmpty) {
      setState(() {
        categories = cats;
        // Reset selected category if it's out of bounds
        if (selectedCategory >= categories.length) {
          selectedCategory = 0;
        }
      });
    }
  }

  // Get amounts for a category, with default values for new categories
  List<double> _getAmountsForCategory(String category) {
    return categoryAmounts[category] ??
        [0, 0, 0, 0, 0, 0, 0]; // Default empty week
  }

  @override
  Widget build(BuildContext context) {
    String currentCategory = categories[selectedCategory];
    List<double> amounts = _getAmountsForCategory(currentCategory);

    // Responsive width and height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Color(0xFFF6F6F6),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Expenses Summary',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [Padding(padding: const EdgeInsets.only(right: 16.0))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Filter
            Padding(
              padding: const EdgeInsets.only(
                top: 24,
                left: 12,
                right: 12,
                bottom: 12,
              ),
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
                    '${categories[selectedCategory]} Expenses',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'June 2, 2025 - June 8, 2025',
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: screenHeight * 0.45, // Make the graph taller
                    width: double.infinity,
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
                                  fontSize: 15,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                if (value % 2000 != 0) return Container();
                                return Text(
                                  '₱${(value ~/ 1000)}K',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
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
                                if (idx < 0 || idx >= days.length) {
                                  return Container();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    days[idx],
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
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
                          horizontalInterval: 2000,
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
            // Income/Expense Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Average Income',
                            style: GoogleFonts.inter(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: AutoSizeText(
                                  '₱12,589.00', // Hardcoded number
                                  maxLines: 1, // Ensure it stays on one line
                                  style: GoogleFonts.inter(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_upward,
                                color: Colors.green,
                                size: 16,
                              ),
                              Text(
                                '+3.5%',
                                style: GoogleFonts.inter(
                                  color: Colors.green,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Average Expense',
                            style: GoogleFonts.inter(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '₱5,543.21',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_downward,
                                color: Colors.red,
                                size: 16,
                              ),
                              Text(
                                '-1.4%',
                                style: GoogleFonts.inter(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
}
