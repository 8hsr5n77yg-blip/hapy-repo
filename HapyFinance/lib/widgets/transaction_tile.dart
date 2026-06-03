import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../widgets/category_icon.dart';
import '../utils/constants.dart';

class TransactionTile extends StatelessWidget {
  final Transaction tx;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TransactionTile({
    super.key,
    required this.tx,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = tx.type == 'expense';
    final amountStr = '${isExpense ? '-' : '+'}¥${tx.amount.toStringAsFixed(2)}';
    final amountColor = isExpense ? AppColors.expenseRed : AppColors.incomeGreen;

    return Dismissible(
      key: Key('tx_${tx.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('确认删除'),
            content: const Text('删除后无法恢复，确定要删除这条记录吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('删除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        onLongPress: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isExpense
                      ? AppColors.expenseRed.withValues(alpha: 0.1)
                      : AppColors.incomeGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CategoryIcon.getIcon(tx.categoryIcon),
                  size: 22,
                  color: isExpense ? AppColors.expenseRed : AppColors.incomeGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.categoryName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          tx.accountName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.subtitle,
                          ),
                        ),
                        if (tx.note.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              tx.note,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.subtitle,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                amountStr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
