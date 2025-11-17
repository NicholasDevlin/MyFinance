import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/accounts_provider.dart';
import '../../models/account.dart';
import '../../theme/app_theme.dart';
import '../../utils/thousand_separator_formatter.dart';

class AccountFormScreen extends StatefulWidget {
  final Account? account; // null for add mode, Account instance for edit mode

  const AccountFormScreen({super.key, this.account});

  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _descriptionController = TextEditingController();

  late AccountType _selectedType;

  // Helper getters
  bool get isEditMode => widget.account != null;
  String get screenTitle => isEditMode ? 'Edit Account' : 'Add New Account';
  String get submitButtonText => isEditMode ? 'Update Account' : 'Add Account';

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      // Initialize with existing account data for edit mode
      _nameController.text = widget.account!.name;
      _balanceController.setNumericValue(widget.account!.balance);
      _descriptionController.text = widget.account!.description ?? '';
      _selectedType = widget.account!.type;
    } else {
      // Initialize with defaults for add mode
      _selectedType = AccountType.bankAccount;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final accountsProvider = Provider.of<AccountsProvider>(context, listen: false);
      bool success;
      String successMessage;

      if (isEditMode) {
        success = await accountsProvider.updateAccount(
          id: widget.account!.id,
          name: _nameController.text.trim(),
          type: _selectedType,
          balance: _balanceController.numericValue ?? 0.0,
          description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        );
        successMessage = 'Account updated successfully';
      } else {
        success = await accountsProvider.createAccount(
          name: _nameController.text.trim(),
          type: _selectedType,
          balance: _balanceController.numericValue ?? 0.0,
          description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        );
        successMessage = 'Account added successfully';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
              ? successMessage
              : accountsProvider.error ?? 'Failed to save account'),
            backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );

        if (success) {
          Navigator.pop(context);
        }
      }
    }
  }

  Future<void> _deleteAccount() async {
    if (!isEditMode) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete "${widget.account!.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final accountsProvider = Provider.of<AccountsProvider>(context, listen: false);
      final success = await accountsProvider.deleteAccount(widget.account!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
              ? 'Account deleted successfully' 
              : accountsProvider.error ?? 'Failed to delete account'),
            backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );

        if (success) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(screenTitle),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Only show delete button in edit mode
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteAccount,
              tooltip: 'Delete Account',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Account Name',
                        prefixIcon: Icon(Icons.account_balance_wallet),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an account name';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

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

                    TextFormField(
                      controller: _balanceController,
                      decoration: InputDecoration(
                        labelText: isEditMode ? 'Current Balance' : 'Initial Balance',
                        prefixText: 'Rp ',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        ThousandSeparatorInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a balance';
                        }

                        final balance = ThousandSeparatorInputFormatter.getNumericValue(value);
                        if (balance == null) {
                          return 'Please enter a valid balance';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: Consumer<AccountsProvider>(
                        builder: (context, provider, _) {
                          return ElevatedButton(
                            onPressed: provider.isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: provider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(submitButtonText),
                          );
                        },
                      ),
                    ),
                  ],
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