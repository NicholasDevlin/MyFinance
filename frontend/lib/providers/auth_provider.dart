import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  AuthProvider(this._apiService) {
    _init();
  }

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isInitialized => _isInitialized;

  Future<void> _init() async {
    await _checkAuth();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _checkAuth() async {
    if (_isLoading) return;

    final token = _apiService.getToken();
    if (token == null) {
      _clearAuth();

      return;
    }

    try {
      final userData = await _apiService.getProfile();
      _setAuth(User.fromJson(userData));
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        await _apiService.clearToken();
        _clearAuth();
      } else {
        _error = 'Network error';
        notifyListeners();
      }
    }
  }

  void _setAuth(User user) {
    _user = user;
    _error = null;
    notifyListeners();
  }

  void _clearAuth() {
    _user = null;
    _error = null;
    notifyListeners();
  }

  // Auth operations
  Future<bool> login(String email, String password) async {
    return _performAuth(() => _apiService.login({
      'email': email,
      'password': password,
    }));
  }

  Future<bool> register(String email, String password, [String? firstName, String? lastName]) async {
    return _performAuth(() => _apiService.register({
      'email': email,
      'password': password,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
    }));
  }

  Future<bool> _performAuth(Future<Map<String, dynamic>> Function() authCall) async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await authCall();
      final token = response['access_token'] as String?;
      final userData = response['user'] as Map<String, dynamic>?;

      if (token == null || userData == null) {
        throw Exception('Invalid response from server');
      }

      await _apiService.saveToken(token);
      _setAuth(User.fromJson(userData));

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _apiService.clearToken();
    _clearAuth();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}