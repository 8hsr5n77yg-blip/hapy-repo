import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MonthPicker extends StatelessWidget {
  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool canGoNext;

  const MonthPicker({
    super.key,
    required this.label,
    required this.onPrevious,
    required this.onNext,
    this.canGoNext = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.cardBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.title,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.title,
            ),
          ),
          IconButton(
            onPressed: canGoNext ? onNext : null,
            icon: const Icon(Icons.chevron_right),
            color: canGoNext ? AppColors.title : AppColors.divider,
          ),
        ],
      ),
    );
  }
}
