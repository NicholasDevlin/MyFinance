import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/categories_provider.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../theme/app_theme.dart';
import '../../utils/number_formatter.dart';
import '../../utils/thousand_separator_formatter.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction;
  final TransactionType? initialType;

  const TransactionFormScreen({
    super.key, 
    this.transaction,
    this.initialType,
  });

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _noteController = TextEditingController();

  late TransactionType _transactionType;
  late DateTime _selectedDate;
  int? _selectedAccountId;
  int? _selectedCategoryId;
  File? _receiptImage;
  String? _existingReceiptImage;

  bool get isEditMode => widget.transaction != null;
  String get screenTitle {
    if (isEditMode) {
      return 'Edit ${widget.transaction!.type.displayName}';
    }

    return 'Add ${_transactionType.displayName}';
  }
  String get submitButtonText => isEditMode ? 'Update' : 'Save';

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      final transaction = widget.transaction!;
      _transactionType = transaction.type;
      _amountController.setNumericValue(transaction.amount);
      _selectedDate = transaction.date;
      _selectedAccountId = transaction.account.id;
      _selectedCategoryId = transaction.category?.id;
      _existingReceiptImage = transaction.receiptImage;
      _noteController.text = transaction.note ?? '';
    } else {
      _transactionType = widget.initialType ?? TransactionType.expense;
      _selectedDate = DateTime.now();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountsProvider = Provider.of<AccountsProvider>(context, listen: false);
      accountsProvider.loadAccounts();

      final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
      final categoryType = _transactionType == TransactionType.income
        ? CategoryType.income 
        : CategoryType.expense;

      if (_transactionType == TransactionType.income && categoriesProvider.incomeCategories.isEmpty) {
        categoriesProvider.loadCategories(type: categoryType);
      } else if (_transactionType == TransactionType.expense && categoriesProvider.expenseCategories.isEmpty) {
        categoriesProvider.loadCategories(type: categoryType);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camera'),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );

    if (source != null) {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _receiptImage = File(image.path);
          _existingReceiptImage = null;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()
        && _selectedAccountId != null
        && _selectedCategoryId != null) {
      final transactionsProvider = Provider.of<TransactionsProvider>(context, listen: false);
      bool success;
      String successMessage;

      if (isEditMode) {
        success = await transactionsProvider.updateTransaction(
          id: widget.transaction!.id,
          amount: _amountController.numericValue ?? 0.0,
          type: _transactionType,
          date: _selectedDate,
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          receiptFile: _receiptImage,
        );
        successMessage = 'Transaction updated successfully';
      } else {
        success = await transactionsProvider.createTransaction(
          amount: _amountController.numericValue ?? 0.0,
          type: _transactionType,
          date: _selectedDate,
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          receiptFile: _receiptImage,
        );
        successMessage = 'Transaction added successfully';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
              ? successMessage
              : transactionsProvider.error ?? 'Failed to save transaction'),
            backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );

        if (success) {
          final accountsProvider = Provider.of<AccountsProvider>(context, listen: false);
          accountsProvider.loadAccounts();

          Navigator.pop(context);
        }
      }
    }
  }

  Future<void> _deleteTransaction() async {
    if (!isEditMode) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete this ${widget.transaction!.type.displayName.toLowerCase()}? This action cannot be undone.'),
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
      final transactionsProvider = Provider.of<TransactionsProvider>(context, listen: false);
      final success = await transactionsProvider.deleteTransaction(widget.transaction!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
              ? 'Transaction deleted successfully' 
              : transactionsProvider.error ?? 'Failed to delete transaction'),
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
      appBar: AppBar(
        title: Text(screenTitle),
        backgroundColor: _transactionType == TransactionType.income 
          ? AppTheme.successColor 
          : AppTheme.errorColor,
        foregroundColor: Colors.white,
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTransaction,
              tooltip: 'Delete Transaction',
            ),
          Consumer<TransactionsProvider>(
            builder: (context, provider, child) {
              return TextButton(
                onPressed: provider.isLoading ? null : _submitForm,
                child: provider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      submitButtonText,
                      style: const TextStyle(color: Colors.white),
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
              if (!isEditMode) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction Type',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<TransactionType>(
                                title: const Text('Income'),
                                value: TransactionType.income,
                                groupValue: _transactionType,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _transactionType = value;
                                      _selectedCategoryId = null;
                                    });

                                    final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
                                    categoriesProvider.loadCategories(type: CategoryType.income);
                                  }
                                },
                                activeColor: AppTheme.successColor,
                              ),
                            ),

                            Expanded(
                              child: RadioListTile<TransactionType>(
                                title: const Text('Expense'),
                                value: TransactionType.expense,
                                groupValue: _transactionType,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _transactionType = value;
                                      _selectedCategoryId = null;
                                    });

                                    final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
                                    categoriesProvider.loadCategories(type: CategoryType.expense);
                                  }
                                },
                                activeColor: AppTheme.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  ThousandSeparatorInputFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'Rp ',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }

                  final amount = ThousandSeparatorInputFormatter.getNumericValue(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('dd MMM yyyy').format(_selectedDate),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Consumer<AccountsProvider>(
                builder: (context, accountsProvider, child) {
                  return DropdownButtonFormField<int>(
                    value: _selectedAccountId,
                    decoration: const InputDecoration(
                      labelText: 'Account',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                      border: OutlineInputBorder(),
                    ),
                    items: accountsProvider.accounts.map((account) {
                      return DropdownMenuItem(
                        value: account.id,
                        child: Text('${account.name} (${NumberFormatter.formatCurrency(account.balance)})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAccountId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an account';
                      }

                      return null;
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              Consumer<CategoriesProvider>(
                builder: (context, categoriesProvider, child) {
                  final categories = _transactionType == TransactionType.income
                      ? categoriesProvider.incomeCategories
                      : categoriesProvider.expenseCategories;

                  return DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Color(int.parse(category.color.replaceFirst('#', '0xFF'))),
                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }

                      return null;
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              if (_transactionType == TransactionType.expense) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Receipt (Optional)',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),

                            TextButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Add Photo'),
                            ),
                          ],
                        ),

                        if (_existingReceiptImage != null && _receiptImage == null) ...[
                          const SizedBox(height: 10),

                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  'http://10.0.2.2:3000/uploads/$_existingReceiptImage',
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(Icons.image_not_supported),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _existingReceiptImage = null;
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (_receiptImage != null) ...[
                          const SizedBox(height: 10),

                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _receiptImage!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _receiptImage = null;
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],

              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}