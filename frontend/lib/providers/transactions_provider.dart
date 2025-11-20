import 'dart:io';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class TransactionsProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // Pagination
  int _currentPage = 1;
  bool _hasNextPage = true;
  int _total = 0;

  // Filters
  int? _filterAccountId;
  int? _filterCategoryId;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  TransactionsProvider(this._apiService) {
    final now = DateTime.now();
    _filterStartDate = DateTime(now.year, now.month, 1);
    _filterEndDate = DateTime.now();
  }

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasNextPage => _hasNextPage;
  int get total => _total;

  // Filter getters
  int? get filterAccountId => _filterAccountId;
  int? get filterCategoryId => _filterCategoryId;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;

  List<Transaction> get incomeTransactions {
    return _transactions.where((t) => t.type == TransactionType.income).toList();
  }

  List<Transaction> get expenseTransactions {
    return _transactions.where((t) => t.type == TransactionType.expense).toList();
  }

  Future<void> loadTransactions({
    TransactionType? type,
    bool refresh = false,
    bool loadMore = false,
  }) async {
    if (loadMore && (_isLoadingMore || !_hasNextPage)) return;

    try {
      if (loadMore) {
        _isLoadingMore = true;
        _currentPage++;
      } else {
        if (refresh) {
          _currentPage = 1;
          _hasNextPage = true;
        }
        _setLoading(true);
      }

      _clearError();

      final result = await _apiService.getTransactions(
        page: _currentPage,
        limit: 10,
        type: type?.value,
        accountId: _filterAccountId,
        categoryId: _filterCategoryId,
        startDate: _filterStartDate?.toIso8601String(),
        endDate: _filterEndDate?.toIso8601String(),
      );

      final transactionsData = result['data'] as List<dynamic>;
      final meta = result['meta'] as Map<String, dynamic>;

      if (refresh || _currentPage == 1) {
        _transactions = transactionsData.map((data) => Transaction.fromJson(data)).toList();
      } else {
        _transactions.addAll(transactionsData.map((data) => Transaction.fromJson(data)).toList());
      }

      _hasNextPage = meta['hasNextPage'] ?? false;
      _total = meta['total'] ?? 0;
    } catch (e) {
      if (loadMore) {
        _currentPage--;
      }

      _setError('Failed to load transactions: $e');
    } finally {
      if (loadMore) {
        _isLoadingMore = false;
      } else {
        _setLoading(false);
      }

      notifyListeners();
    }
  }

  // Update filters and reload
  Future<void> updateFilters({
    int? accountId,
    int? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _filterAccountId = accountId;
    _filterCategoryId = categoryId;
    _filterStartDate = startDate;
    _filterEndDate = endDate;

    await loadTransactions(refresh: true);
  }

  // Clear filters
  Future<void> clearFilters() async {
    _filterAccountId = null;
    _filterCategoryId = null;
    final now = DateTime.now();
    _filterStartDate = DateTime(now.year, now.month, 1);
    _filterEndDate = DateTime.now();

    await loadTransactions(refresh: true);
  }

  // Create new transaction
  Future<bool> createTransaction({
    required double amount,
    required TransactionType type,
    required DateTime date,
    required int accountId,
    int? categoryId,
    String? note,
    File? receiptFile,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final transactionData = await _apiService.createTransaction(
        {
          'amount': amount,
          'type': type.value,
          'date': date.toIso8601String(),
          'accountId': accountId,
          'categoryId': categoryId,
          'note': note,
        },
        receiptFile: receiptFile,
      );

      final newTransaction = Transaction.fromJson(transactionData);
      _transactions.insert(0, newTransaction);

      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to create transaction: $e');

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update transaction
  Future<bool> updateTransaction({
    required int id,
    double? amount,
    TransactionType? type,
    DateTime? date,
    int? accountId,
    int? categoryId,
    String? note,
    File? receiptFile,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final updateData = <String, dynamic>{};
      if (amount != null) updateData['amount'] = amount;
      if (type != null) updateData['type'] = type.value;
      if (date != null) updateData['date'] = date.toIso8601String();
      if (accountId != null) updateData['accountId'] = accountId;
      if (categoryId != null) updateData['categoryId'] = categoryId;
      if (note != null) updateData['note'] = note;

      final transactionData = await _apiService.updateTransaction(
        id,
        updateData,
        receiptFile: receiptFile,
      );

      final updatedTransaction = Transaction.fromJson(transactionData);
      final index = _transactions.indexWhere((transaction) => transaction.id == id);
      if (index != -1) {
        _transactions[index] = updatedTransaction;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to update transaction: $e');

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete transaction
  Future<bool> deleteTransaction(int id) async {
    try {
      _setLoading(true);
      _clearError();

      await _apiService.deleteTransaction(id);
      _transactions.removeWhere((transaction) => transaction.id == id);

      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to delete transaction: $e');

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get transaction by ID
  Transaction? getTransactionById(int id) {
    try {
      return _transactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get transactions for current month
  List<Transaction> getCurrentMonthTransactions() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _transactions.where((transaction) {
      return transaction.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  // Calculate monthly summary
  Map<String, double> getCurrentMonthSummary() {
    final monthlyTransactions = getCurrentMonthTransactions();

    double totalIncome = 0;
    double totalExpenses = 0;

    for (final transaction in monthlyTransactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += transaction.amount;
      }
    }

    return {
      'income': totalIncome,
      'expenses': totalExpenses,
      'balance': totalIncome - totalExpenses,
    };
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

  // Clear all data (called when user logs out)
  void clearData() {
    _transactions = [];
    _error = null;
    _isLoading = false;
    _isLoadingMore = false;
    _currentPage = 1;
    _hasNextPage = true;
    _total = 0;
    _filterAccountId = null;
    _filterCategoryId = null;

    final now = DateTime.now();
    _filterStartDate = DateTime(now.year, now.month, 1);
    _filterEndDate = DateTime.now();

    notifyListeners();
  }
}