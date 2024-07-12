import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/transaction_service.dart';
import '../models/transaction.dart';
import 'transaction_detail_screen.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class TransactionListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final transactionService = Provider.of<TransactionService>(context);

    final currentUser = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTransactionScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: currentUser == null
          ? Center(child: Text('Please login to view transactions'))
          : StreamBuilder<List<Transaction>>(
              stream: transactionService.getTransactions(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No transactions available'));
                }

                final transactions = snapshot.data!;
                final balance = calculateBalance(transactions);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser != null ? 'Hi, ${currentUser.displayName}' : 'Hi, Guest',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Current Balance: \Rp. ${balance.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16.0), // Optional: Add some spacing
                          Divider(), // Optional: Add a divider
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20),
                              title: Text(transaction.name),
                              subtitle: Text(transaction.date.toString()),
                              trailing: Text(
                                '${transaction.type == 'expense' ? '-' : ''}\Rp. ${transaction.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: transaction.type == 'income' ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TransactionDetailScreen(
                                      transaction: transaction,
                                    ),
                                  ),
                                );
                              },
                              onLongPress: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Container(
                                    padding: EdgeInsets.all(16),
                                    child: Wrap(
                                      children: [
                                        ListTile(
                                          leading: Icon(Icons.edit),
                                          title: Text('Edit Transaction'),
                                          onTap: () {
                                            Navigator.pop(context); // Close modal
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditTransactionScreen(
                                                  transaction: transaction,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.delete),
                                          title: Text('Delete Transaction'),
                                          onTap: () {
                                            Navigator.pop(context); // Close modal
                                            transactionService.deleteTransaction(transaction.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  double calculateBalance(List<Transaction> transactions) {
    double income = transactions
        .where((t) => t.type == 'income')
        .map((t) => t.amount)
        .fold(0.0, (a, b) => a + b);

    double expense = transactions
        .where((t) => t.type == 'expense')
        .map((t) => t.amount)
        .fold(0.0, (a, b) => a + b);

    return income - expense; // Return net balance
  }
}
