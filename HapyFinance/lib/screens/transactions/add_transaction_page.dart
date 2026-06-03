import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../models/account.dart';
import '../../providers/account_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/category_icon.dart';
import '../../utils/constants.dart';

class AddTransactionPage extends StatefulWidget {
  final Transaction? existingTx;

  const AddTransactionPage({super.key, this.existingTx});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense';
  int? _selectedCategoryId;
  int? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> _categories = [];
  List<Account> _accounts = [];
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _categories = AppConstants.expenseCategories;
    _accounts = context.read<AccountProvider>().accounts;
    _selectedAccountId = _accounts.isNotEmpty ? _accounts.first.id : null;

    if (widget.existingTx != null) {
      _isEdit = true;
      final tx = widget.existingTx!;
      _amountController.text = tx.amount.toStringAsFixed(2);
      _noteController.text = tx.note;
      _type = tx.type;
      _selectedCategoryId = tx.categoryId;
      _selectedAccountId = tx.accountId;
      _selectedDate = DateTime.parse(tx.date);
      _updateCategories();
    } else {
      _updateCategories();
      if (_categories.isNotEmpty) {
        _selectedCategoryId = _categories.first['id'] as int;
      }
    }
  }

  void _updateCategories() {
    setState(() {
      _categories = _type == 'expense'
          ? AppConstants.expenseCategories
          : AppConstants.incomeCategories;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入金额')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的正数金额')),
      );
      return;
    }

    // validate 2 decimal places
    final parts = amountText.split('.');
    if (parts.length == 2 && parts[1].length > 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('金额最多支持两位小数')),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择分类')),
      );
      return;
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择账户')),
      );
      return;
    }

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final timeStr = DateFormat('HH:mm').format(now);

    if (_isEdit) {
      final oldTx = widget.existingTx!;
      final newTx = oldTx.copyWith(
        type: _type,
        amount: amount,
        categoryId: _selectedCategoryId!,
        accountId: _selectedAccountId!,
        date: dateStr,
        time: timeStr,
        note: _noteController.text.trim(),
        updatedAt: now,
      );
      await context.read<TransactionProvider>().updateTransaction(oldTx, newTx);
    } else {
      final tx = Transaction(
        type: _type,
        amount: amount,
        categoryId: _selectedCategoryId!,
        accountId: _selectedAccountId!,
        date: dateStr,
        time: timeStr,
        note: _noteController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );
      await context.read<TransactionProvider>().addTransaction(tx);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('zh'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy年MM月dd日').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '编辑记录' : '记一笔'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              '保存',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // amount input
            Center(
              child: SizedBox(
                width: 250,
                child: TextField(
                  controller: _amountController,
                  autofocus: !_isEdit,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    prefixText: '¥ ',
                    prefixStyle: TextStyle(fontSize: 24, color: AppColors.subtitle),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // type toggle
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _type = 'expense';
                        _updateCategories();
                        _selectedCategoryId = _categories.isNotEmpty
                            ? _categories.first['id'] as int
                            : null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _type == 'expense'
                            ? AppColors.expenseRed
                            : Colors.grey[200],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '支出',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _type = 'income';
                        _updateCategories();
                        _selectedCategoryId = _categories.isNotEmpty
                            ? _categories.first['id'] as int
                            : null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _type == 'income'
                            ? AppColors.incomeGreen
                            : Colors.grey[200],
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '收入',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // category grid
            const Text('选择分类',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.subtitle,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final catId = cat['id'] as int;
                final catName = cat['name'] as String;
                final catIcon = cat['icon'] as String;
                final selected = _selectedCategoryId == catId;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryId = catId),
                  child: Container(
                    width: 72,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryLight : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          CategoryIcon.getIcon(catIcon),
                          size: 24,
                          color: selected
                              ? AppColors.primary
                              : AppColors.subtitle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          catName,
                          style: TextStyle(
                            fontSize: 12,
                            color: selected
                                ? AppColors.primary
                                : AppColors.title,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // date picker
            const Text('日期',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.subtitle,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 20, color: AppColors.subtitle),
                    const SizedBox(width: 8),
                    Text(dateStr,
                        style: const TextStyle(
                            fontSize: 16, color: AppColors.title)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // account picker
            const Text('账户',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.subtitle,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedAccountId,
                  isExpanded: true,
                  hint: const Text('选择账户'),
                  items: _accounts.map((a) {
                    return DropdownMenuItem<int>(
                      value: a.id,
                      child: Text('${a.name} (¥${a.balance.toStringAsFixed(2)})'),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedAccountId = v),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // note
            const Text('备注（可选）',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.subtitle,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: '添加备注...',
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
