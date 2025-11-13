import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

/// A stateless widget that displays a bar chart showing spending data over time.
///
/// The `GraphReportCard` widget visualizes spending patterns for a specific category
/// across different time periods (daily or weekly). It uses the `fl_chart` package
/// to render an interactive bar chart with tooltips. The widget can optionally
/// include an "Analytics" button for navigation to a detailed analytics page.
///
/// When there is no transaction data available, the widget displays a placeholder
/// message encouraging users to add transactions.
class GraphReportCard extends StatelessWidget {
  /// The name of the category being displayed (e.g., "Food", "Transport").
  final String categoryName;

  /// The selected time period for the chart (e.g., "Week", "Month", "Year").
  final String selectedPeriod;

  /// A human-readable date range string (e.g., "Jan 1 - Jan 7, 2024").
  final String dateRange;

  /// The list of spending amounts corresponding to each bar in the chart.
  final List<double> chartData;

  /// The list of labels for the x-axis (e.g., day names or week numbers).
  final List<String> chartLabels;

  /// The list of full date strings used in tooltips when hovering over bars.
  final List<String> chartDates;

  /// An optional callback invoked when the "Analytics" button is tapped.
  ///
  /// This is only displayed when used on the HomePage. If null, the button
  /// is not shown.
  final VoidCallback? onAnalyticsTap;

  /// Creates a `GraphReportCard` widget.
  ///
  /// The [categoryName], [selectedPeriod], [dateRange], [chartData],
  /// [chartLabels], and [chartDates] parameters are required.
  ///
  /// The [onAnalyticsTap] parameter is optional and should be provided
  /// when the widget is used on the HomePage to enable navigation to analytics.
  const GraphReportCard({
    super.key,
    required this.categoryName,
    required this.selectedPeriod,
    required this.dateRange,
    required this.chartData,
    required this.chartLabels,
    required this.chartDates,
    this.onAnalyticsTap,
  });

  /// Calculates the maximum Y-axis value for the chart.
  ///
  /// Returns 1000 if the chart data is empty or all values are zero.
  /// Otherwise, returns 120% of the maximum value in [chartData], rounded up.
  double get maxY {
    if (chartData.isEmpty || chartData.every((element) => element == 0)) {
      return 1000;
    }
    final max = chartData.reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble();
  }

  /// Determines the index of the bar with the highest value in [chartData].
  ///
  /// This bar will be highlighted with a different color in the chart.
  /// Returns 0 if the chart data is empty.
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
    double screenHeight = MediaQuery.of(context).size.height;
    // Determine if this widget is being used on the HomePage.
    bool isHomePage = onAnalyticsTap != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          // Header section with title, date range, and optional Analytics button.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the chart title based on category and period.
                    Text(
                      '$categoryName ${selectedPeriod == 'Week'
                          ? 'Daily'
                          : selectedPeriod == 'Month'
                          ? 'Daily'
                          : 'Weekly'} Spending',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Display the date range.
                    Text(
                      dateRange,
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              // Show Analytics button only on HomePage.
              if (isHomePage)
                GestureDetector(
                  onTap: onAnalyticsTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Analytics',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // Chart section - displays either a bar chart or a placeholder message.
          SizedBox(
            height: screenHeight * 0.45,
            width: double.infinity,
            child:
                chartData.isEmpty || chartData.every((element) => element == 0)
                    ? // Display placeholder when no data is available.
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transaction data available',
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start adding transactions to see analytics',
                            style: GoogleFonts.inter(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                    : // Display the bar chart when data is available.
                    BarChart(
                      BarChartData(
                        maxY: maxY,
                        minY: 0,
                        // Configure touch interactions and tooltips.
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final dateText =
                                  chartDates.length > group.x
                                      ? chartDates[group.x]
                                      : 'Unknown date';
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
                        // Configure axis titles and labels.
                        titlesData: FlTitlesData(
                          // Left axis (Y-axis) showing spending amounts.
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                final interval =
                                    maxY > 10000
                                        ? 5000
                                        : (maxY > 1000 ? 1000 : 500);
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
                          // Bottom axis (X-axis) showing time labels.
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
                          // Hide right and top axis titles.
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        // Configure grid lines.
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval:
                              maxY > 10000 ? 5000 : (maxY > 1000 ? 1000 : 500),
                          getDrawingHorizontalLine:
                              (value) => FlLine(
                                color: Colors.grey[200],
                                strokeWidth: 1,
                              ),
                        ),
                        borderData: FlBorderData(show: false),
                        // Generate bar chart data with highlighting for the highest value.
                        barGroups: List.generate(chartData.length, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: chartData[index],
                                // Highlight the bar with the highest value in black.
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
    );
  }
}
