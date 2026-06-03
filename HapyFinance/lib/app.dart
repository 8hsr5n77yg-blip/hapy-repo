import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/account_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_page.dart';
import 'utils/constants.dart';

class JijianApp extends StatelessWidget {
  const JijianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProxyProvider<AuthProvider, AccountProvider>(
          create: (_) => AccountProvider(),
          update: (_, auth, prev) => prev!..api = auth.api,
        ),
        ChangeNotifierProxyProvider<AuthProvider, TransactionProvider>(
          create: (_) => TransactionProvider(),
          update: (_, auth, prev) => prev!..api = auth.api,
        ),
      ],
      child: MaterialApp(
        title: 'hapy·记账',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.title,
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            color: AppColors.cardBackground,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
              ),
            ),
          ),
        ),
        home: const _AppEntry(),
      ),
    );
  }
}

class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AuthProvider>().tryAutoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (ctx, auth, _) {
        if (auth.initializing) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_wallet,
                      size: 64, color: Color(0xFF4CAF50)),
                  SizedBox(height: 16),
                  Text('hapy·记账',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        }
        return auth.isLoggedIn ? const HomeScreen() : const LoginPage();
      },
    );
  }
}
