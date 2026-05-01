import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: AppTheme.pageBackground(isDark: isDark),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: AppTheme.foregroundGlow(isDark: isDark),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Lead Conversions', isDark),
                    const SizedBox(height: 16),
                    _buildConversionChart(isDark),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Revenue vs Expenses', isDark),
                    const SizedBox(height: 16),
                    _buildFinancialChart(isDark),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Attendance Trends', isDark),
                    const SizedBox(height: 16),
                    _buildAttendanceChart(isDark),
                    const SizedBox(height: 32),
                    _buildKeyMetrics(isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildConversionChart(bool isDark) {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 32),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(color: Colors.green, value: 40, title: '40%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            PieChartSectionData(color: Colors.orange, value: 30, title: '30%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            PieChartSectionData(color: Colors.red, value: 30, title: '30%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildFinancialChart(bool isDark) {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 32),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 15, color: AppColors.primary, width: 16)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: AppColors.error, width: 16)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 18, color: AppColors.primary, width: 16)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 8, color: AppColors.error, width: 16)]),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceChart(bool isDark) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 32),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2), FlSpot(4, 5)],
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard('Retention Rate', '85%', Icons.loop_rounded, Colors.blue, isDark),
        _buildMetricCard('Avg Revenue/User', '₹2,400', Icons.wallet_rounded, Colors.green, isDark),
        _buildMetricCard('Churn Rate', '12%', Icons.person_remove_rounded, Colors.red, isDark),
        _buildMetricCard('Lead -> Member', '22%', Icons.trending_up_rounded, Colors.orange, isDark),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
