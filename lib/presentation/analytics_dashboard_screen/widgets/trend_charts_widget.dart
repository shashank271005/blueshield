import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TrendChartsWidget extends StatefulWidget {
  final String selectedRange;

  const TrendChartsWidget({
    super.key,
    required this.selectedRange,
  });

  @override
  State<TrendChartsWidget> createState() => _TrendChartsWidgetState();
}

class _TrendChartsWidgetState extends State<TrendChartsWidget> {
  int selectedChartIndex = 0;

  final List<Map<String, dynamic>> chartData = [
    {
      'title': 'Report Frequency',
      'data': [
        {'x': 1, 'y': 45},
        {'x': 2, 'y': 52},
        {'x': 3, 'y': 38},
        {'x': 4, 'y': 67},
        {'x': 5, 'y': 73},
        {'x': 6, 'y': 58},
        {'x': 7, 'y': 82},
      ],
      'color': Color(0xFF1565C0),
    },
    {
      'title': 'Verification Rates',
      'data': [
        {'x': 1, 'y': 85},
        {'x': 2, 'y': 78},
        {'x': 3, 'y': 92},
        {'x': 4, 'y': 88},
        {'x': 5, 'y': 95},
        {'x': 6, 'y': 82},
        {'x': 7, 'y': 90},
      ],
      'color': Color(0xFF388E3C),
    },
    {
      'title': 'Hazard Distribution',
      'data': [
        {'x': 1, 'y': 25},
        {'x': 2, 'y': 35},
        {'x': 3, 'y': 28},
        {'x': 4, 'y': 42},
        {'x': 5, 'y': 38},
        {'x': 6, 'y': 45},
        {'x': 7, 'y': 52},
      ],
      'color': Color(0xFFF57C00),
    },
  ];

  List<FlSpot> _getSpots(List<Map<String, dynamic>> data) {
    return data
        .map((point) => FlSpot(
              (point['x'] as int).toDouble(),
              (point['y'] as int).toDouble(),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trend Analysis',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            height: 5.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chartData.length,
              itemBuilder: (context, index) {
                final isSelected = selectedChartIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedChartIndex = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 2.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? chartData[index]['color'].withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? chartData[index]['color']
                            : AppTheme.lightTheme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        chartData[index]['title'],
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? chartData[index]['color']
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        AppTheme.lightTheme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          );
                          Widget text;
                          switch (value.toInt()) {
                            case 1:
                              text = const Text('Mon', style: style);
                              break;
                            case 2:
                              text = const Text('Tue', style: style);
                              break;
                            case 3:
                              text = const Text('Wed', style: style);
                              break;
                            case 4:
                              text = const Text('Thu', style: style);
                              break;
                            case 5:
                              text = const Text('Fri', style: style);
                              break;
                            case 6:
                              text = const Text('Sat', style: style);
                              break;
                            case 7:
                              text = const Text('Sun', style: style);
                              break;
                            default:
                              text = const Text('', style: style);
                              break;
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: text,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  minX: 1,
                  maxX: 7,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getSpots(chartData[selectedChartIndex]['data']),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          chartData[selectedChartIndex]['color'],
                          chartData[selectedChartIndex]['color']
                              .withValues(alpha: 0.3),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: chartData[selectedChartIndex]['color'],
                            strokeWidth: 2,
                            strokeColor:
                                AppTheme.lightTheme.colorScheme.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            chartData[selectedChartIndex]['color']
                                .withValues(alpha: 0.3),
                            chartData[selectedChartIndex]['color']
                                .withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          return LineTooltipItem(
                            '${barSpot.y.toInt()}',
                            TextStyle(
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
