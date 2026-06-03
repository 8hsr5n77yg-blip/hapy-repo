import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _loading = false;
  double _monthlyIncome = 0;
  double _monthlyExpense = 0;
  List<Map<String, dynamic>> _categoryStatsExpense = [];
  List<Map<String, dynamic>> _categoryStatsIncome = [];
  List<Map<String, dynamic>> _monthlyTrend = [];
  ApiService? _api;

  List<Transaction> get transactions => _transactions;
  bool get loading => _loading;
  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpense => _monthlyExpense;
  double get monthlyBalance => _monthlyIncome - _monthlyExpense;
  List<Map<String, dynamic>> get categoryStatsExpense => _categoryStatsExpense;
  List<Map<String, dynamic>> get categoryStatsIncome => _categoryStatsIncome;
  List<Map<String, dynamic>> get monthlyTrend => _monthlyTrend;

  set api(ApiService api) => _api = api;

  Future<void> loadTransactions(String yearMonth) async {
    if (_api == null) return;
    _loading = true;
    notifyListeners();

    final result = await _api!.get('/transactions', queryParams: {'month': yearMonth});
    _transactions = (result as List)
        .map((j) => Transaction.fromMap(j as Map<String, dynamic>))
        .toList();

    final summary = await _api!.get('/statistics/summary', queryParams: {'month': yearMonth});
    final s = summary as Map<String, dynamic>;
    _monthlyIncome = (s['income'] as num).toDouble();
    _monthlyExpense = (s['expense'] as num).toDouble();

    final catExpense = await _api!.get('/statistics/category',
        queryParams: {'month': yearMonth, 'type': 'expense'});
    _categoryStatsExpense = (catExpense as List)
        .map((j) => j as Map<String, dynamic>)
        .toList();

    final catIncome = await _api!.get('/statistics/category',
        queryParams: {'month': yearMonth, 'type': 'income'});
    _categoryStatsIncome = (catIncome as List)
        .map((j) => j as Map<String, dynamic>)
        .toList();

    final trend = await _api!.get('/statistics/trend');
    _monthlyTrend = (trend as List)
        .map((j) => j as Map<String, dynamic>)
        .toList();

    _loading = false;
    notifyListeners();
  }

  Future<int> addTransaction(Transaction tx) async {
    final result = await _api!.post('/transactions', body: tx.toMap());
    return (result as Map<String, dynamic>)['id'] as int;
  }

  Future<void> updateTransaction(Transaction oldTx, Transaction newTx) async {
    await _api!.put('/transactions/${newTx.id}', body: newTx.toMap());
  }

  Future<void> deleteTransaction(int id) async {
    await _api!.delete('/transactions/$id');
  }

  Future<List<Map<String, dynamic>>> exportAll() async {
    final result = await _api!.get('/transactions/export');
    return (result as List).map((j) => j as Map<String, dynamic>).toList();
  }

  Future<void> deleteAllTransactions() async {
    await _api!.delete('/transactions/clear');
  }

  Map<String, List<Transaction>> get groupedTransactions {
    final map = <String, List<Transaction>>{};
    for (final tx in _transactions) {
      map.putIfAbsent(tx.date, () => []).add(tx);
    }
    return map;
  }

  List<String> get sortedDates {
    final dates = groupedTransactions.keys.toList();
    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }
}
