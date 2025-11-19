import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transactions_provider.dart';
import '../../models/transaction.dart';
import '../../theme/app_theme.dart';
import 'transaction_form_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionsProvider>(context, listen: false).loadTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Income'),
            Tab(text: 'Expenses'),
          ],
        ),
      ),
      body: Consumer<TransactionsProvider>(
        builder: (context, transactionsProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildTransactionsList(transactionsProvider.transactions),
              _buildTransactionsList(transactionsProvider.incomeTransactions),
              _buildTransactionsList(transactionsProvider.expenseTransactions),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionsList(List<Transaction> transactions) {
    return Consumer<TransactionsProvider>(
      builder: (context, transactionsProvider, child) {
        if (transactionsProvider.isLoading && transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (transactionsProvider.error != null && transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(transactionsProvider.error!),
                ElevatedButton(
                  onPressed: () => transactionsProvider.loadTransactions(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),

                const SizedBox(height: 16),

                Text(
                  'No transactions yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Add your first transaction to get started',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransactionFormScreen(
                              initialType: TransactionType.income,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Income'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                      ),
                    ),

                    const SizedBox(width: 12),

                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransactionFormScreen(
                              initialType: TransactionType.expense,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.remove),
                      label: const Text('Add Expense'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: transactionsProvider.loadTransactions,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionCard(transaction);
            },
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppTheme.successColor : AppTheme.errorColor;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            isIncome ? Icons.trending_up : Icons.trending_down,
            color: color,
          ),
        ),
        title: Text(
          transaction.category?.name ?? 'Uncategorized',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.account.name),
            Text(
              DateFormat('MMM dd, yyyy').format(transaction.date),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (transaction.note != null) ...[
              const SizedBox(height: 4),
              Text(
                transaction.note!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              transaction.displayAmount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
            if (transaction.receiptImage != null)
              Icon(
                Icons.attach_file,
                size: 16,
                color: Colors.grey[600],
              ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Center(
                      child: Text(
                        transaction.displayAmount,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: transaction.type == TransactionType.income 
                              ? AppTheme.successColor 
                              : AppTheme.errorColor,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildDetailRow('Category', transaction.category?.name ?? 'Uncategorized'),
                    _buildDetailRow('Account', transaction.account.name),
                    _buildDetailRow('Date', DateFormat('EEEE, MMMM dd, yyyy').format(transaction.date)),
                    _buildDetailRow('Type', transaction.type.displayName),
                    
                    if (transaction.note != null)
                      _buildDetailRow('Note', transaction.note!),
                    
                    if (transaction.receiptImage != null) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Receipt',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'http://10.0.2.2:3000/uploads/${transaction.receiptImage}',
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
                    ],

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransactionFormScreen(
                                    transaction: transaction,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: const BorderSide(color: AppTheme.primaryColor),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showDeleteConfirmation(transaction);
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete this ${transaction.type.displayName.toLowerCase()} of ${transaction.formattedAmount}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final transactionsProvider = Provider.of<TransactionsProvider>(context, listen: false);
              final success = await transactionsProvider.deleteTransaction(transaction.id);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success 
                      ? 'Transaction deleted successfully' 
                      : transactionsProvider.error ?? 'Failed to delete transaction'),
                    backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}