import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SummaryCard extends StatelessWidget {
  final double income;
  final double expense;

  const SummaryCard({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '月结余',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '¥${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItem('月收入', income, Colors.white),
              Container(width: 1, height: 30, color: Colors.white30),
              _buildItem('月支出', expense, Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          '¥${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
