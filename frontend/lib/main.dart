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

class MyApp extends StatefulWidget {
  final ApiService apiService;

  const MyApp({super.key, required this.apiService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authProvider = AuthProvider(widget.apiService);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: widget.apiService),
        
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProxyProvider<AuthProvider, AccountsProvider>(
          create: (_) => AccountsProvider(widget.apiService),
          update: (_, auth, previous) {
            if (!auth.isLoggedIn) {
              previous?.clearData();
            }

            return previous ?? AccountsProvider(widget.apiService);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, TransactionsProvider>(
          create: (_) => TransactionsProvider(widget.apiService),
          update: (_, auth, previous) {
            if (!auth.isLoggedIn) {
              previous?.clearData();
            }

            return previous ?? TransactionsProvider(widget.apiService);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, CategoriesProvider>(
          create: (_) => CategoriesProvider(widget.apiService),
          update: (_, auth, previous) {
            if (!auth.isLoggedIn) {
              previous?.clearData();
            }

            return previous ?? CategoriesProvider(widget.apiService);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, DashboardProvider>(
          create: (_) => DashboardProvider(widget.apiService),
          update: (_, auth, previous) {
            if (!auth.isLoggedIn) {
              previous?.clearData();
            }

            return previous ?? DashboardProvider(widget.apiService);
          },
        ),
      ],
      child: MaterialApp(
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