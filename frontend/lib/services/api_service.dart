import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // static const String baseUrl = 'http://localhost:3000'; // Web and development
  static const String baseUrl = 'http://10.0.2.2:3000'; // Android emulator localhost
  // For physical device testing, use your computer's IP address:
  // static const String baseUrl = 'http://192.168.1.XXX:3000'; // Replace XXX with your IP
  
  late final Dio _dio;
  final SharedPreferences _prefs; // For storing small pieces of data persistently on the device

  ApiService(this._prefs) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add token interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          print('⚠️ 401 Unauthorized - Token might be invalid');
          // Don't automatically clear token here, let auth provider handle it
          // This prevents clearing valid tokens due to temporary network issues
        }
        handler.next(error);
      },
    ));
  }

  // Token management
  String? getToken() {
    return _prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    await _prefs.remove('auth_token');
  }

  bool get hasToken => getToken() != null;

  // Auth endpoints
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await _dio.post('/auth/register', data: data);

    return response.data;
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final response = await _dio.post('/auth/login', data: data);

    return response.data;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/auth/profile');

    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.patch('/users/profile', data: data);

    return response.data;
  }

  // Accounts endpoints
  Future<List<dynamic>> getAccounts() async {
    final response = await _dio.get('/accounts');

    return response.data;
  }

  Future<Map<String, dynamic>> createAccount(Map<String, dynamic> data) async {
    final response = await _dio.post('/accounts', data: data);

    return response.data;
  }

  Future<Map<String, dynamic>> updateAccount(int id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/accounts/$id', data: data);

    return response.data;
  }

  Future<void> deleteAccount(int id) async {
    await _dio.delete('/accounts/$id');
  }

  // Transactions endpoints
  Future<Map<String, dynamic>> getTransactions({
    int? page,
    int? limit,
    String? type,
    int? accountId,
    int? categoryId,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (type != null) queryParams['type'] = type;
    if (accountId != null) queryParams['accountId'] = accountId;
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _dio.get('/transactions', queryParameters: queryParams);

    return response.data;
  }

  Future<Map<String, dynamic>> createTransaction(
    Map<String, dynamic> data, 
    {File? receiptFile} // Make it a named optional parameter
  ) async {
    FormData formData = FormData.fromMap(data);

    if (receiptFile != null) {
      formData.files.add(MapEntry(
        'receipt',
        await MultipartFile.fromFile(
          receiptFile.path,
          filename: receiptFile.path.split('/').last,
        ),
      ));
    }

    final response = await _dio.post('/transactions', data: formData);

    return response.data;
  }

  Future<Map<String, dynamic>> updateTransaction(
    int id, 
    Map<String, dynamic> data,
    {File? receiptFile}
  ) async {
    FormData formData = FormData.fromMap(data);

    if (receiptFile != null) {
      formData.files.add(MapEntry(
        'receipt',
        await MultipartFile.fromFile(
          receiptFile.path,
          filename: receiptFile.path.split('/').last,
        ),
      ));
    }

    final response = await _dio.patch('/transactions/$id', data: formData);

    return response.data;
  }

  Future<void> deleteTransaction(int id) async {
    await _dio.delete('/transactions/$id');
  }

  // Categories endpoints
  Future<List<dynamic>> getCategories({String? type}) async {
    final queryParams = <String, dynamic>{};
    if (type != null) queryParams['type'] = type;

    final response = await _dio.get('/categories', queryParameters: queryParams);

    return response.data;
  }

  // Dashboard endpoints
  Future<Map<String, dynamic>> getDashboardData() async {
    final response = await _dio.get('/dashboard');

    return response.data;
  }

  Future<Map<String, dynamic>> getYearlyOverview(int year) async {
    final response = await _dio.get('/dashboard/yearly/$year');

    return response.data;
  }

  Future<List<dynamic>> getSpendingByCategory() async {
    final response = await _dio.get('/dashboard/spending-by-category');

    return response.data;
  }
}