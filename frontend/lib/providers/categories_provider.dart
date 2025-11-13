import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class CategoriesProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoriesProvider(this._apiService);

  // Getters
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<Category> get incomeCategories {
    return _categories.where((cat) => cat.type == CategoryType.income).toList();
  }
  
  List<Category> get expenseCategories {
    return _categories.where((cat) => cat.type == CategoryType.expense).toList();
  }

  // Load all categories
  Future<void> loadCategories({CategoryType? type}) async {
    try {
      _setLoading(true);
      _clearError();

      final categoriesData = await _apiService.getCategories(
        type: type?.value,
      );
      _categories = categoriesData.map((data) => Category.fromJson(data)).toList();
    } catch (e) {
      _setError('Failed to load categories: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create new category
  Future<bool> createCategory({
    required String name,
    required CategoryType type,
    String? description,
    String color = '#007bff',
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final categoryData = await _apiService.createCategory({
        'name': name,
        'type': type.value,
        'description': description,
        'color': color,
      });

      final newCategory = Category.fromJson(categoryData);
      _categories.insert(0, newCategory);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create category: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get category by ID
  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get categories by type
  List<Category> getCategoriesByType(CategoryType type) {
    return _categories.where((category) => category.type == type).toList();
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