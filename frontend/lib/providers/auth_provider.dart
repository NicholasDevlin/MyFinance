import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._apiService) {
    _checkAuthStatus();
  }

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null && _apiService.isLoggedIn;

  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    if (_apiService.isLoggedIn) {
      try {
        await loadUserProfile();
      } catch (e) {
        await logout();
      }
    }
  }

  // Load user profile
  Future<void> loadUserProfile() async {
    try {
      _setLoading(true);
      final userData = await _apiService.getProfile();
      _user = User.fromJson(userData);
      _clearError();
    } catch (e) {
      _setError('Failed to load user profile: $e');
      await logout();
    } finally {
      _setLoading(false);
    }
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _apiService.register({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      });

      // Save token and user data
      final accessToken = response['access_token'];
      final userData = response['user'];
      
      if (accessToken == null) {
        throw Exception('No access token received from server');
      }
      if (userData == null) {
        throw Exception('No user data received from server');
      }
      
      await _apiService.saveToken(accessToken);
      _user = User.fromJson(userData);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _apiService.login({
        'email': email,
        'password': password,
      });

      // Save token and user data
      final accessToken = response['access_token'];
      final userData = response['user'];
      
      if (accessToken == null) {
        throw Exception('No access token received from server');
      }
      if (userData == null) {
        throw Exception('No user data received from server');
      }
      
      await _apiService.saveToken(accessToken);
      _user = User.fromJson(userData);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _apiService.clearToken();
      _user = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
    }
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
}