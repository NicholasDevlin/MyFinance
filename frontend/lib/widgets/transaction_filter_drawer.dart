import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transactions_provider.dart';
import '../providers/accounts_provider.dart';
import '../providers/categories_provider.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

class TransactionFilterDrawer extends StatefulWidget {
  const TransactionFilterDrawer({super.key});

  @override
  State<TransactionFilterDrawer> createState() => _TransactionFilterDrawerState();
}

class _TransactionFilterDrawerState extends State<TransactionFilterDrawer> {
  int? _selectedAccountId;
  int? _selectedCategoryId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final transactionsProvider = Provider.of<TransactionsProvider>(context, listen: false);
    _selectedAccountId = transactionsProvider.filterAccountId;
    _selectedCategoryId = transactionsProvider.filterCategoryId;

    final now = DateTime.now();
    _startDate = transactionsProvider.filterStartDate ?? DateTime(now.year, now.month, 1);
    _endDate = transactionsProvider.filterEndDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Drawer(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              color: AppTheme.primaryColor,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Transactions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Customize your transaction view',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Consumer<AccountsProvider>(
                      builder: (context, accountsProvider, child) {
                        return DropdownButtonFormField<int?>(
                          value: _selectedAccountId,
                          decoration: const InputDecoration(
                            hintText: 'All Accounts',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.account_balance),
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All Accounts'),
                            ),
                            ...accountsProvider.accounts.map((Account account) {
                              return DropdownMenuItem<int?>(
                                value: account.id,
                                child: Text(account.name),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedAccountId = value;
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Consumer<CategoriesProvider>(
                      builder: (context, categoriesProvider, child) {
                        return DropdownButtonFormField<int?>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(
                            hintText: 'All Categories',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All Categories'),
                            ),
                            ...categoriesProvider.categories.map((Category category) {
                              return DropdownMenuItem<int?>(
                                value: category.id,
                                child: Text(category.name),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Date Range',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      controller: TextEditingController(
                        text: _startDate != null
                            ? DateFormat('MMM dd, yyyy').format(_startDate!)
                            : DateFormat('MMM dd, yyyy').format(DateTime(DateTime.now().year, DateTime.now().month, 1)),
                      ),
                      onTap: () => _selectStartDate(),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      controller: TextEditingController(
                        text: _endDate != null
                            ? DateFormat('MMM dd, yyyy').format(_endDate!)
                            : DateFormat('MMM dd, yyyy').format(DateTime.now()),
                      ),
                      onTap: () => _selectEndDate(),
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clearFilters,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text('Clear'),
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: _applyFilters,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text(
                              'Apply',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime(now.year, now.month, 1),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _clearFilters() {
    final transactionsProvider = Provider.of<TransactionsProvider>(context, listen: false);
    transactionsProvider.clearFilters();
    Navigator.pop(context);
  }

  void _applyFilters() {
    final transactionsProvider = Provider.of<TransactionsProvider>(context, listen: false);
    transactionsProvider.updateFilters(
      accountId: _selectedAccountId,
      categoryId: _selectedCategoryId,
      startDate: _startDate,
      endDate: _endDate,
    );
    Navigator.pop(context);
  }
}