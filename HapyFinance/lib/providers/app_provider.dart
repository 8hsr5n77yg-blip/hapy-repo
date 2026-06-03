import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  DateTime get selectedMonth => _selectedMonth;

  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  void goToPreviousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  void goToNextMonth() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (nextMonth.isAfter(currentMonth)) return;
    _selectedMonth = nextMonth;
    notifyListeners();
  }

  String get selectedMonthLabel {
    return '${_selectedMonth.year}年${_selectedMonth.month}月';
  }

  String get selectedYearMonth {
    return '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';
  }
}
