import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction.dart';
import '../../widgets/month_picker.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/empty_state.dart';
import 'add_transaction_page.dart';

class TransactionListPage extends StatelessWidget {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final txProvider = context.watch<TransactionProvider>();

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final canGoNext = appProvider.selectedMonth.isBefore(currentMonth);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('hapy·记账'),
        centerTitle: true,
      ),
      body: Column(
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
          SummaryCard(
            income: txProvider.monthlyIncome,
            expense: txProvider.monthlyExpense,
          ),
          Expanded(
            child: txProvider.loading
                ? const Center(child: CircularProgressIndicator())
                : txProvider.transactions.isEmpty
                    ? const EmptyState(message: '还没有记录，点击下方按钮开始记账')
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: txProvider.sortedDates.length,
                        itemBuilder: (context, index) {
                          final date = txProvider.sortedDates[index];
                          final txs = txProvider.groupedTransactions[date]!;
                          return _DateGroup(
                            date: date,
                            transactions: txs,
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionPage()),
          ).then((_) {
            txProvider.loadTransactions(appProvider.selectedYearMonth);
            // also refresh accounts to get updated balances
            context.read<AccountProvider>().loadAccounts();
          });
        },
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('记一笔'),
      ),
    );
  }
}

class _DateGroup extends StatelessWidget {
  final String date;
  final List<Transaction> transactions;

  const _DateGroup({required this.date, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final parsed = DateTime.tryParse(date);
    String label = date;
    if (parsed != null) {
      final weekDays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
      final month = parsed.month;
      final day = parsed.day;
      final wd = weekDays[parsed.weekday - 1];
      label = '$month月$day日 $wd';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF757575),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (int i = 0; i < transactions.length; i++) ...[
                TransactionTile(
                  tx: transactions[i],
                  onTap: () {},
                  onDelete: () async {
                    final txProvider = context.read<TransactionProvider>();
                    await txProvider.deleteTransaction(transactions[i].id!);
                    final yearMonth =
                        context.read<AppProvider>().selectedYearMonth;
                    await txProvider.loadTransactions(yearMonth);
                  },
                  onEdit: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddTransactionPage(existingTx: transactions[i]),
                      ),
                    ).then((_) {
                      final yearMonth =
                          context.read<AppProvider>().selectedYearMonth;
                      context
                          .read<TransactionProvider>()
                          .loadTransactions(yearMonth);
                    });
                  },
                ),
                if (i < transactions.length - 1)
                  const Divider(height: 1, indent: 56),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
