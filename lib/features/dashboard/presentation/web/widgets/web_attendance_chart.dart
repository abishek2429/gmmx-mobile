import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class WebAttendanceChart extends StatelessWidget {
  final bool isDark;

  const WebAttendanceChart({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard(radius: 20, isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Member Attendance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: AppTheme.glassButton(isDark: isDark),
                child: const Row(
                  children: [
                    Text('Last 6 Months', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                        String text;
                        switch (value.toInt()) {
                          case 0: text = 'Jan'; break;
                          case 1: text = 'Feb'; break;
                          case 2: text = 'Mar'; break;
                          case 3: text = 'Apr'; break;
                          case 4: text = 'May'; break;
                          case 5: text = 'Jun'; break;
                          default: text = ''; break;
                        }
                        return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroupData(0, 12, 4),
                  _makeGroupData(1, 15, 3),
                  _makeGroupData(2, 13, 5),
                  _makeGroupData(3, 17, 2),
                  _makeGroupData(4, 14, 4),
                  _makeGroupData(5, 16, 3),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Present', AppColors.primary),
              const SizedBox(width: 24),
              _buildLegendItem('Absent', isDark ? Colors.white24 : Colors.black12),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(toY: y1, color: AppColors.primary, width: 8, borderRadius: BorderRadius.circular(4)),
        BarChartRodData(toY: y2, color: isDark ? Colors.white24 : Colors.black12, width: 8, borderRadius: BorderRadius.circular(4)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
