import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/app_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/month_picker.dart';
import '../../utils/constants.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final txProvider = context.watch<TransactionProvider>();

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final canGoNext = appProvider.selectedMonth.isBefore(currentMonth);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('统计看板')),
      body: txProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  MonthPicker(
                    label: appProvider.selectedMonthLabel,
                    onPrevious: () {
                      appProvider.goToPreviousMonth();
                      txProvider.loadTransactions(appProvider.selectedYearMonth);
                    },
                    onNext: () {
                      appProvider.goToNextMonth();
                      txProvider.loadTransactions(appProvider.selectedYearMonth);
                    },
                    canGoNext: canGoNext,
                  ),
                  const SizedBox(height: 16),

                  // expense pie chart
                  _buildSectionTitle('支出分类占比'),
                  const SizedBox(height: 8),
                  _buildPieChart(
                    stats: txProvider.categoryStatsExpense,
                    total: txProvider.monthlyExpense,
                    isExpense: true,
                  ),
                  const SizedBox(height: 24),

                  // income pie chart
                  _buildSectionTitle('收入分类占比'),
                  const SizedBox(height: 8),
                  _buildPieChart(
                    stats: txProvider.categoryStatsIncome,
                    total: txProvider.monthlyIncome,
                    isExpense: false,
                  ),
                  const SizedBox(height: 24),

                  // monthly trend
                  _buildSectionTitle('近6个月趋势'),
                  const SizedBox(height: 8),
                  _buildTrendChart(txProvider.monthlyTrend),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.title,
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart({
    required List<Map<String, dynamic>> stats,
    required double total,
    required bool isExpense,
  }) {
    if (stats.isEmpty || total == 0) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        child: const Center(
          child: Text('暂无数据', style: TextStyle(color: AppColors.subtitle)),
        ),
      );
    }

    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
      const Color(0xFFFF5722),
      const Color(0xFF607D8B),
      const Color(0xFF795548),
      const Color(0xFFCDDC39),
      const Color(0xFF3F51B5),
      const Color(0xFFFFEB3B),
      const Color(0xFF009688),
      const Color(0xFF673AB7),
      const Color(0xFFF44336),
      const Color(0xFF8BC34A),
    ];

    final sections = <PieChartSectionData>[];
    for (int i = 0; i < stats.length; i++) {
      final stat = stats[i];
      final pct = ((stat['total'] as num).toDouble() / total * 100);
      sections.add(PieChartSectionData(
        color: colors[i % colors.length],
        value: (stat['total'] as num).toDouble(),
        title: '${pct.toStringAsFixed(1)}%',
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 50,
                    sectionsSpace: 2,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isExpense ? '总支出' : '总收入',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.subtitle),
                    ),
                    Text(
                      '¥${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.title,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: List.generate(stats.length, (i) {
              final stat = stats[i];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${stat['name']} ¥${(stat['total'] as num).toDouble().toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.subtitle),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(List<Map<String, dynamic>> trend) {
    if (trend.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        child: const Center(
          child: Text('暂无数据', style: TextStyle(color: AppColors.subtitle)),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: null,
                barGroups: List.generate(trend.length, (i) {
                  final item = trend[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: (item['expense'] as num).toDouble(),
                        color: AppColors.expenseRed,
                        width: 14,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: (item['income'] as num).toDouble(),
                        color: AppColors.incomeGreen,
                        width: 14,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < trend.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              trend[idx]['month'] as String,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.subtitle),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: false),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppColors.expenseRed, '支出'),
              const SizedBox(width: 24),
              _legendDot(AppColors.incomeGreen, '收入'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.subtitle)),
      ],
    );
  }
}
