import '../utils/number_formatter.dart';

enum AccountType {
  bankAccount('bank_account', 'Bank Account'),
  cash('cash', 'Cash'),
  creditCard('credit_card', 'Credit Card'),
  eWallet('e_wallet', 'E-Wallet');

  const AccountType(this.value, this.displayName);
  
  final String value;
  final String displayName;
  
  static AccountType fromValue(String value) {
    return AccountType.values.firstWhere((type) => type.value == value);
  }
}

class Account {
  final int id;
  final String name;
  final AccountType type;
  final double balance;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      type: AccountType.fromValue(json['type']),
      balance: double.parse(json['balance'].toString()),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'balance': balance,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedBalance {
    return NumberFormatter.formatCurrency(balance);
  }
}