import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../models/account.dart';
import '../../utils/constants.dart';
import 'account_form_page.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  @override
  void initState() {
    super.initState();
    context.read<AccountProvider>().loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('资产账户'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountFormPage()),
              ).then((_) => provider.loadAccounts());
            },
          ),
        ],
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.accounts.isEmpty
              ? const Center(
                  child: Text('还没有账户，点击右上角 + 添加',
                      style: TextStyle(color: AppColors.subtitle)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.accounts.length,
                  itemBuilder: (context, index) {
                    final account = provider.accounts[index];
                    return _AccountCard(account: account);
                  },
                ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;

  const _AccountCard({required this.account});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (account.type) {
      case 'cash':
        icon = Icons.money;
        break;
      case 'bank':
        icon = Icons.account_balance;
        break;
      default:
        icon = Icons.credit_card;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AccountFormPage(existingAccount: account),
            ),
          ).then((_) => context.read<AccountProvider>().loadAccounts());
        },
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppConstants.accountTypeLabel(account.type),
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.subtitle),
                    ),
                  ],
                ),
              ),
              Text(
                '¥${account.balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.subtitle),
            ],
          ),
        ),
      ),
    );
  }
}
