import 'account.dart';
import 'category.dart';
import '../utils/number_formatter.dart';

enum TransactionType {
  income('income', 'Income'),
  expense('expense', 'Expense');

  const TransactionType(this.value, this.displayName);
  
  final String value;
  final String displayName;
  
  static TransactionType fromValue(String value) {
    return TransactionType.values.firstWhere((type) => type.value == value);
  }
}

class Transaction {
  final int id;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? note;
  final String? receiptImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Account account;
  final Category? category;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    this.receiptImage,
    required this.createdAt,
    required this.updatedAt,
    required this.account,
    this.category,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: double.parse(json['amount'].toString()),
      type: TransactionType.fromValue(json['type']),
      date: DateTime.parse(json['date']),
      note: json['note'],
      receiptImage: json['receiptImage'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      account: Account.fromJson(json['account']),
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.value,
      'date': date.toIso8601String(),
      'note': note,
      'receiptImage': receiptImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'account': account.toJson(),
      'category': category?.toJson(),
    };
  }

  String get formattedAmount {
    return NumberFormatter.formatCurrency(amount);
  }

  String get displayAmount {
    final prefix = type == TransactionType.income ? '+' : '-';
    return '$prefix${formattedAmount}';
  }
}