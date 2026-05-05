import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';

class AttendanceHistoryPage extends ConsumerWidget {
  const AttendanceHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final attendance = [
      _AttendanceRecord(DateTime.now(), "08:15 AM", "09:45 AM", "Main Branch", true),
      _AttendanceRecord(DateTime.now().subtract(const Duration(days: 1)), "08:30 AM", "10:00 AM", "Main Branch", true),
      _AttendanceRecord(DateTime.now().subtract(const Duration(days: 2)), "-", "-", "-", false),
      _AttendanceRecord(DateTime.now().subtract(const Duration(days: 3)), "09:00 AM", "10:30 AM", "Main Branch", true),
      _AttendanceRecord(DateTime.now().subtract(const Duration(days: 4)), "08:10 AM", "09:30 AM", "Main Branch", true),
      _AttendanceRecord(DateTime.now().subtract(const Duration(days: 5)), "08:45 AM", "10:15 AM", "Main Branch", true),
      _AttendanceRecord(DateTime.now().subtract(const Duration(days: 6)), "09:00 AM", "10:30 AM", "Main Branch", true),
    ];

    return Scaffold(
      body: Container(
        decoration: AppTheme.pageBackground(isDark: isDark),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: AppTheme.foregroundGlow(isDark: isDark),
              ),
            ),
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      size: 20,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'ATTENDANCE LOG',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    centerTitle: true,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildStatsSummary(isDark),
                        const SizedBox(height: 32),
                        const Row(
                          children: [
                            Text(
                              'RECENT SESSIONS',
                              style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildAttendanceTile(attendance[index], isDark),
                      childCount: attendance.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 32),
      child: Row(
        children: [
          _statCircle('85%', 'CONSISTENCY', AppColors.primary),
          const Spacer(),
          _statColumn('24', 'TOTAL DAYS', isDark),
          const SizedBox(width: 24),
          _statColumn('12', 'STREAK', isDark),
        ],
      ),
    );
  }

  Widget _statCircle(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.2), width: 6),
          ),
          child: Center(
            child: Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _statColumn(String value, String label, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.textPrimary)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildAttendanceTile(_AttendanceRecord record, bool isDark) {
    final dateStr = DateFormat('EEEE, MMM d').format(record.date);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(isDark: isDark, radius: 24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: record.isPresent 
                      ? AppColors.success.withOpacity(0.1) 
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  record.isPresent ? Icons.check_rounded : Icons.close_rounded,
                  color: record.isPresent ? AppColors.success : AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.isPresent ? "Verified Entry" : "No Activity Recorded",
                      style: TextStyle(
                        color: record.isPresent ? AppColors.success : AppColors.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (record.isPresent) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: Colors.grey, thickness: 0.1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _timeInfo('CHECK IN', record.checkIn, Icons.login_rounded, isDark),
                _timeInfo('CHECK OUT', record.checkOut, Icons.logout_rounded, isDark),
                _timeInfo('LOCATION', record.location, Icons.location_on_rounded, isDark),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeInfo(String label, String value, IconData icon, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimary)),
      ],
    );
  }
}

class _AttendanceRecord {
  final DateTime date;
  final String checkIn;
  final String checkOut;
  final String location;
  final bool isPresent;
  _AttendanceRecord(this.date, this.checkIn, this.checkOut, this.location, this.isPresent);
}
