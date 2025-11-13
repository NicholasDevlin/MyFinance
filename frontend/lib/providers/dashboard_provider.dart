import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService;
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _spendingByCategory = [];
  bool _isLoading = false;
  String? _error;

  DashboardProvider(this._apiService);

  // Getters
  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<dynamic> get spendingByCategory => _spendingByCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load dashboard data
  Future<void> loadDashboardData() async {
    try {
      _setLoading(true);
      _clearError();

      _dashboardData = await _apiService.getDashboardData();
    } catch (e) {
      _setError('Failed to load dashboard data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load spending by category
  Future<void> loadSpendingByCategory() async {
    try {
      _setLoading(true);
      _clearError();

      _spendingByCategory = await _apiService.getSpendingByCategory();
    } catch (e) {
      _setError('Failed to load spending by category: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load yearly overview
  Future<Map<String, dynamic>?> getYearlyOverview(int year) async {
    try {
      _setLoading(true);
      _clearError();

      final data = await _apiService.getYearlyOverview(year);
      return data;
    } catch (e) {
      _setError('Failed to load yearly overview: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Get current month summary from dashboard data
  Map<String, dynamic>? get currentMonthSummary {
    return _dashboardData?['currentMonth'];
  }

  // Get previous month summary from dashboard data
  Map<String, dynamic>? get previousMonthSummary {
    return _dashboardData?['previousMonth'];
  }

  // Get total balance from dashboard data
  double get totalBalance {
    return (_dashboardData?['totalBalance'] ?? 0.0).toDouble();
  }

  // Get accounts from dashboard data
  List<dynamic> get accounts {
    return _dashboardData?['accounts'] ?? [];
  }

  // Get comparison data
  Map<String, dynamic>? get comparison {
    return _dashboardData?['comparison'];
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Refresh all dashboard data
  Future<void> refresh() async {
    await Future.wait([
      loadDashboardData(),
      loadSpendingByCategory(),
    ]);
  }
}