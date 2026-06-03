import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4CAF50);
  static const primaryDark = Color(0xFF388E3C);
  static const primaryLight = Color(0xFFC8E6C9);
  static const title = Color(0xFF212121);
  static const subtitle = Color(0xFF757575);
  static const background = Color(0xFFF5F5F5);
  static const cardBackground = Colors.white;
  static const expenseRed = Color(0xFFE53935);
  static const incomeGreen = Color(0xFF4CAF50);
  static const divider = Color(0xFFE0E0E0);
}

class AppConstants {
  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;

  static const List<Map<String, dynamic>> expenseCategories = [
    {'id': 1, 'name': '餐饮', 'icon': 'restaurant', 'sortOrder': 1},
    {'id': 2, 'name': '交通', 'icon': 'directions_car', 'sortOrder': 2},
    {'id': 3, 'name': '购物', 'icon': 'shopping_bag', 'sortOrder': 3},
    {'id': 4, 'name': '住房', 'icon': 'home', 'sortOrder': 4},
    {'id': 5, 'name': '娱乐', 'icon': 'movie', 'sortOrder': 5},
    {'id': 6, 'name': '医疗', 'icon': 'local_hospital', 'sortOrder': 6},
    {'id': 7, 'name': '教育', 'icon': 'school', 'sortOrder': 7},
    {'id': 8, 'name': '人情', 'icon': 'people', 'sortOrder': 8},
    {'id': 9, 'name': '日用', 'icon': 'lightbulb', 'sortOrder': 9},
    {'id': 10, 'name': '其他', 'icon': 'more_horiz', 'sortOrder': 10},
  ];

  static const List<Map<String, dynamic>> incomeCategories = [
    {'id': 11, 'name': '工资', 'icon': 'work', 'sortOrder': 1},
    {'id': 12, 'name': '奖金', 'icon': 'card_giftcard', 'sortOrder': 2},
    {'id': 13, 'name': '兼职', 'icon': 'handyman', 'sortOrder': 3},
    {'id': 14, 'name': '理财', 'icon': 'trending_up', 'sortOrder': 4},
    {'id': 15, 'name': '退款', 'icon': 'money_off', 'sortOrder': 5},
    {'id': 16, 'name': '其他', 'icon': 'more_horiz', 'sortOrder': 6},
  ];

  static const accountTypes = [
    {'value': 'cash', 'label': '现金'},
    {'value': 'bank', 'label': '银行卡'},
    {'value': 'virtual', 'label': '虚拟账户'},
  ];

  static String accountTypeLabel(String type) {
    switch (type) {
      case 'cash':
        return '现金';
      case 'bank':
        return '银行卡';
      case 'virtual':
        return '虚拟账户';
      default:
        return type;
    }
  }
}
