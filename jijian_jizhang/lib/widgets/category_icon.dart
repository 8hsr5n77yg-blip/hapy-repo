import 'package:flutter/material.dart';

class CategoryIcon {
  static IconData getIcon(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'home':
        return Icons.home;
      case 'movie':
        return Icons.movie;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'people':
        return Icons.people;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'work':
        return Icons.work;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'handyman':
        return Icons.handyman;
      case 'trending_up':
        return Icons.trending_up;
      case 'money_off':
        return Icons.money_off;
      case 'more_horiz':
        return Icons.more_horiz;
      case 'wallet':
        return Icons.wallet;
      case 'account_balance':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      default:
        return Icons.circle;
    }
  }
}
