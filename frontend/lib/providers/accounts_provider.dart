import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/api_service.dart';

class AccountsProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Account> _accounts = [];
  bool _isLoading = false;
  String? _error;

  AccountsProvider(this._apiService);

  // Getters
  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  double get totalBalance {
    return _accounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  // Load all accounts
  Future<void> loadAccounts() async {
    try {
      _setLoading(true);
      _clearError();

      final accountsData = await _apiService.getAccounts();
      _accounts = accountsData.map((data) => Account.fromJson(data)).toList();
    } catch (e) {
      _setError('Failed to load accounts: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create new account
  Future<bool> createAccount({
    required String name,
    required AccountType type,
    double balance = 0.0,
    String? description,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final accountData = await _apiService.createAccount({
        'name': name,
        'type': type.value,
        'balance': balance,
        'description': description,
      });

      final newAccount = Account.fromJson(accountData);
      _accounts.insert(0, newAccount);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create account: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update account
  Future<bool> updateAccount({
    required int id,
    String? name,
    AccountType? type,
    double? balance,
    String? description,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (type != null) updateData['type'] = type.value;
      if (balance != null) updateData['balance'] = balance;
      if (description != null) updateData['description'] = description;

      final accountData = await _apiService.updateAccount(id, updateData);
      final updatedAccount = Account.fromJson(accountData);

      final index = _accounts.indexWhere((account) => account.id == id);
      if (index != -1) {
        _accounts[index] = updatedAccount;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to update account: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<bool> deleteAccount(int id) async {
    try {
      _setLoading(true);
      _clearError();

      await _apiService.deleteAccount(id);
      _accounts.removeWhere((account) => account.id == id);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete account: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get account by ID
  Account? getAccountById(int id) {
    try {
      return _accounts.firstWhere((account) => account.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get accounts by type
  List<Account> getAccountsByType(AccountType type) {
    return _accounts.where((account) => account.type == type).toList();
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