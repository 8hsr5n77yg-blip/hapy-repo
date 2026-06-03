import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/api_service.dart';

class AccountProvider extends ChangeNotifier {
  List<Account> _accounts = [];
  bool _loading = false;
  ApiService? _api;

  List<Account> get accounts => _accounts;
  bool get loading => _loading;
  bool get hasAccounts => _accounts.isNotEmpty;

  set api(ApiService api) => _api = api;

  Future<void> loadAccounts() async {
    if (_api == null) return;
    _loading = true;
    notifyListeners();
    final result = await _api!.get('/accounts');
    _accounts = (result as List)
        .map((j) => Account.fromMap(j as Map<String, dynamic>))
        .toList();
    _loading = false;
    notifyListeners();
  }

  Future<int> addAccount(Account account) async {
    final result = await _api!.post('/accounts', body: account.toMap());
    await loadAccounts();
    return (result as Map<String, dynamic>)['id'] as int;
  }

  Future<void> updateAccount(Account account) async {
    final now = DateTime.now();
    final updated = account.copyWith(updatedAt: now);
    await _api!.put('/accounts/${account.id}', body: updated.toMap());
    await loadAccounts();
  }

  Future<void> deleteAccount(int id) async {
    await _api!.delete('/accounts/$id');
    await loadAccounts();
  }
}
