import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/transaction_provider.dart';
import 'transactions/transaction_list_page.dart';
import 'statistics/statistics_page.dart';
import 'profile/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = const [
    TransactionListPage(),
    StatisticsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final yearMonth = context.read<AppProvider>().selectedYearMonth;
    await context.read<TransactionProvider>().loadTransactions(yearMonth);
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: const Color(0xFF757575),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: '流水'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: '统计'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}
