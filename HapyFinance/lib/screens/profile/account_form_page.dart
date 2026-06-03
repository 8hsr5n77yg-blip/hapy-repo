import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../models/account.dart';
import '../../utils/constants.dart';

class AccountFormPage extends StatefulWidget {
  final Account? existingAccount;

  const AccountFormPage({super.key, this.existingAccount});

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _type = 'cash';
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingAccount != null) {
      _isEdit = true;
      final a = widget.existingAccount!;
      _nameController.text = a.name;
      _balanceController.text = a.initialBalance.toStringAsFixed(2);
      _type = a.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入账户名称')),
      );
      return;
    }

    final balanceText = _balanceController.text.trim();
    final balance = double.tryParse(balanceText);
    if (balance == null || balance < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的初始余额')),
      );
      return;
    }

    final now = DateTime.now();
    final provider = context.read<AccountProvider>();

    if (_isEdit) {
      final updated = widget.existingAccount!.copyWith(
        name: name,
        type: _type,
        initialBalance: balance,
        updatedAt: now,
      );
      await provider.updateAccount(updated);
    } else {
      final account = Account(
        name: name,
        type: _type,
        balance: balance,
        initialBalance: balance,
        createdAt: now,
        updatedAt: now,
      );
      await provider.addAccount(account);
      context.read<AccountProvider>().loadAccounts();
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '编辑账户' : '添加账户'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('账户名称',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.subtitle,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '例如：现金、工商银行、支付宝',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('账户类型',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.subtitle,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: AppConstants.accountTypes.map((t) {
                final value = t['value'] as String;
                final label = t['label'] as String;
                final selected = _type == value;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: value == 'virtual' ? 0 : 8,
                    ),
                    child: GestureDetector(
                      onTap: () => setState(() => _type = value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primaryLight : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.divider,
                          ),
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selected
                                ? AppColors.primary
                                : AppColors.title,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            const Text('初始余额',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.subtitle,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _balanceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: '¥ ',
                hintText: '0.00',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
