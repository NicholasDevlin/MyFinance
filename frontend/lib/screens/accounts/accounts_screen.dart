import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/accounts_provider.dart';
import '../../models/account.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_card.dart';
import '../../utils/number_formatter.dart';
import 'account_form_screen.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountsProvider>(context, listen: false).loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountFormScreen(), // No account = add mode
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AccountsProvider>(
        builder: (context, accountsProvider, child) {
          if (accountsProvider.isLoading && accountsProvider.accounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (accountsProvider.error != null && accountsProvider.accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(accountsProvider.error!),
                  ElevatedButton(
                    onPressed: () => accountsProvider.loadAccounts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (accountsProvider.accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No accounts yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first account to get started',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountFormScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Account'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: accountsProvider.loadAccounts,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.primaryColorLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        NumberFormatter.formatCurrency(accountsProvider.totalBalance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: accountsProvider.accounts.length,
                    itemBuilder: (context, index) {
                      final account = accountsProvider.accounts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AccountCard(
                          account: account,
                          onTap: () => _showAccountOptions(account),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAccountOptions(Account account) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            ListTile(
              title: Text(account.name),
              subtitle: Text('${account.type.displayName} • ${account.formattedBalance}'),
            ),

            const Divider(),

            ListTile(
              leading: Icon(
                Icons.edit,
                color: account.canModify ? null : Colors.grey,
              ),
              title: Text(
                'Edit Account',
                style: TextStyle(
                  color: account.canModify ? null : Colors.grey,
                ),
              ),
              subtitle: account.canModify ? null : Text(
                'Cannot edit account with ${account.transactionCount} transaction(s)',
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
              onTap: account.canModify ? () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountFormScreen(account: account),
                  ),
                );
              } : () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cannot edit account that has ${account.transactionCount} transaction(s). Please delete all transactions first.'),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(
                Icons.delete,
                color: account.canModify ? Colors.red : Colors.grey,
              ),
              title: Text(
                'Delete Account',
                style: TextStyle(
                  color: account.canModify ? Colors.red : Colors.grey,
                ),
              ),
              subtitle: account.canModify ? null : Text(
                'Cannot delete account with ${account.transactionCount} transaction(s)',
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
              onTap: account.canModify ? () {
                Navigator.pop(context);
                _showDeleteConfirmation(account);
              } : () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cannot delete account that has ${account.transactionCount} transaction(s). Please delete all transactions first.'),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete "${account.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final accountsProvider = Provider.of<AccountsProvider>(context, listen: false);
              final success = await accountsProvider.deleteAccount(account.id);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success 
                      ? 'Account deleted successfully' 
                      : accountsProvider.error ?? 'Failed to delete account'),
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