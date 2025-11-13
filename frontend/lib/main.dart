import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'providers/accounts_provider.dart';
import 'providers/transactions_provider.dart';
import 'providers/categories_provider.dart';
import 'providers/dashboard_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  final apiService = ApiService(prefs);
  
  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  
  const MyApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide API service
        Provider<ApiService>.value(value: apiService),
        
        // State providers
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => AccountsProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionsProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoriesProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(apiService),
        ),
      ],
      child: MaterialApp(
        title: 'MyFinance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}