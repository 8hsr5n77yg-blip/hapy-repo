import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  User? _user;
  bool _loading = false;
  bool _initializing = true;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;
  bool get initializing => _initializing;
  String? get token => _api.token;
  ApiService get api => _api;

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    final savedPhone = prefs.getString('phone');

    if (savedToken == null || savedPhone == null) {
      _initializing = false;
      notifyListeners();
      return;
    }

    _api.setToken(savedToken);
    try {
      final result = await _api.get('/auth/me');
      _user = User(
        id: result['id'] as int,
        phone: result['phone'] as String,
      );
    } catch (_) {
      _api.setToken(null);
      await prefs.remove('token');
      await prefs.remove('phone');
    }

    _initializing = false;
    notifyListeners();
  }

  Future<void> sendCode(String phone) async {
    _loading = true;
    notifyListeners();
    try {
      await _api.post('/auth/send-code', body: {'phone': phone});
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> login(String phone, String code) async {
    _loading = true;
    notifyListeners();
    try {
      final result = await _api.post('/auth/login', body: {
        'phone': phone,
        'code': code,
      });
      _api.setToken(result['token'] as String);
      _user = User.fromJson(result['user'] as Map<String, dynamic>);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _api.token!);
      await prefs.setString('phone', _user!.phone);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    _api.setToken(null);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('phone');
  }
}
