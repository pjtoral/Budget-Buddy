import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphReportCard extends StatelessWidget {
  final String categoryName;
  final String selectedPeriod;
  final String dateRange;
  final List<double> chartData;
  final List<String> chartLabels;
  final List<String> chartDates;
  final VoidCallback? onAnalyticsTap; // Only for HomePage

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

  double get maxY {
    if (chartData.isEmpty || chartData.every((element) => element == 0)) {
      return 1000;
    }
    final max = chartData.reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble();
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
    double screenHeight = MediaQuery.of(context).size.height;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
          SizedBox(
            height: screenHeight * 0.45,
            width: double.infinity,
            child:
                chartData.isEmpty || chartData.every((element) => element == 0)
                    ? Center(
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
                    : BarChart(
                      BarChartData(
                        maxY: maxY,
                        minY: 0,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.black,
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
                        titlesData: FlTitlesData(
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
                          horizontalInterval:
                              maxY > 10000 ? 5000 : (maxY > 1000 ? 1000 : 500),
                          getDrawingHorizontalLine:
                              (value) => FlLine(
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
