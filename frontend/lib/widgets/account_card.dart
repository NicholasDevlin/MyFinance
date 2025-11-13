import 'package:flutter/material.dart';
import '../models/account.dart';
import '../theme/app_theme.dart';

class AccountCard extends StatelessWidget {
  final dynamic account; // Can be Account model or Map from API
  final VoidCallback? onTap;

  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String name = account is Map ? account['name'] : account.name;
    final String typeValue = account is Map ? account['type'] : account.type.value;
    final double balance = account is Map 
        ? double.parse(account['balance'].toString()) 
        : account.balance;

    Color getAccountTypeColor() {
      switch (typeValue) {
        case 'bank_account':
          return FinanceColors.bankAccount;
        case 'cash':
          return FinanceColors.cash;
        case 'credit_card':
          return FinanceColors.creditCard;
        case 'e_wallet':
          return FinanceColors.eWallet;
        default:
          return AppTheme.primaryColor;
      }
    }

    IconData getAccountTypeIcon() {
      switch (typeValue) {
        case 'bank_account':
          return Icons.account_balance;
        case 'cash':
          return Icons.payments;
        case 'credit_card':
          return Icons.credit_card;
        case 'e_wallet':
          return Icons.account_balance_wallet;
        default:
          return Icons.account_balance_wallet;
      }
    }

    String getAccountTypeName() {
      switch (typeValue) {
        case 'bank_account':
          return 'Bank Account';
        case 'cash':
          return 'Cash';
        case 'credit_card':
          return 'Credit Card';
        case 'e_wallet':
          return 'E-Wallet';
        default:
          return 'Account';
      }
    }

    final color = getAccountTypeColor();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    getAccountTypeIcon(),
                    color: color,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                getAccountTypeName(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${balance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}