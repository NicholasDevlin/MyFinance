import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/accounts_provider.dart';
import '../../models/account.dart';
import '../../theme/app_theme.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  AccountType _selectedType = AccountType.bankAccount;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      final accountsProvider = Provider.of<AccountsProvider>(context, listen: false);
      
      final success = await accountsProvider.createAccount(
        name: _nameController.text.trim(),
        type: _selectedType,
        balance: double.tryParse(_balanceController.text) ?? 0.0,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(accountsProvider.error ?? 'Failed to create account'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Account'),
        actions: [
          Consumer<AccountsProvider>(
            builder: (context, provider, child) {
              return TextButton(
                onPressed: provider.isLoading ? null : _saveAccount,
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Account Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                  hintText: 'e.g., Main Checking Account',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an account name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Account Type Selection
              Text(
                'Account Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              
              ...AccountType.values.map((type) {
                return RadioListTile<AccountType>(
                  title: Text(type.displayName),
                  subtitle: Text(_getAccountTypeDescription(type)),
                  value: type,
                  groupValue: _selectedType,
                  onChanged: (AccountType? value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                  secondary: Icon(_getAccountTypeIcon(type)),
                );
              }).toList(),
              
              const SizedBox(height: 20),
              
              // Initial Balance Field
              TextFormField(
                controller: _balanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Initial Balance',
                  prefixText: '\$ ',
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: '0.00',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final balance = double.tryParse(value);
                    if (balance == null || balance < 0) {
                      return 'Please enter a valid balance';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                  hintText: 'Add any notes about this account...',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAccountTypeDescription(AccountType type) {
    switch (type) {
      case AccountType.bankAccount:
        return 'Checking, savings, or other bank accounts';
      case AccountType.cash:
        return 'Physical cash in wallet or at home';
      case AccountType.creditCard:
        return 'Credit card accounts';
      case AccountType.eWallet:
        return 'Digital wallets like PayPal, Venmo, etc.';
    }
  }

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.bankAccount:
        return Icons.account_balance;
      case AccountType.cash:
        return Icons.payments;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.eWallet:
        return Icons.account_balance_wallet;
    }
  }
}