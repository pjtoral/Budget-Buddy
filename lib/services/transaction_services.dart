import 'package:budgetbuddy_project/models/transaction_model.dart';
import 'package:budgetbuddy_project/services/local_storage_service.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';

class TransactionServices {
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  
  // Get all transactions
  Future<List<TransactionModel>> getAllTransactions() async {
    final allTransactions = _localStorageService.getTransactions();
    return allTransactions ?? [];
  }
  
  // Get all inflow transactions (positive amounts)
  Future<List<TransactionModel>> getInflow() async {
    final allTransactions = _localStorageService.getTransactions();
    return allTransactions?.where((t) => t.amount > 0).toList() ?? [];
  }

  // Get all outflow transactions (negative amounts)
  Future<List<TransactionModel>> getOutflow() async {
    final allTransactions = _localStorageService.getTransactions();
    return allTransactions?.where((t) => t.amount < 0).toList() ?? [];
  }

  // Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    final current = _localStorageService.getTransactions() ?? [];
    await _localStorageService.saveTransactions([...current, transaction]);
  }

  // Get transactions by category
  Future<List<TransactionModel>> getTransactionByCategory(String category) async {
    final transactions = _localStorageService.getTransactions();
    return transactions?.where((t) => t.category == category).toList() ?? [];
  }

  // Delete a transaction
  Future<void> deleteTransaction(TransactionModel transaction) async {
    final current = _localStorageService.getTransactions() ?? [];
    current.removeWhere((t) => 
      t.date == transaction.date && 
      t.amount == transaction.amount && 
      t.category == transaction.category
    );
    await _localStorageService.saveTransactions(current);
  }

  // Update a transaction
  Future<void> updateTransaction(
    TransactionModel oldTransaction, 
    TransactionModel newTransaction
  ) async {
    final current = _localStorageService.getTransactions() ?? [];
    final index = current.indexWhere((t) => 
      t.date == oldTransaction.date && 
      t.amount == oldTransaction.amount && 
      t.category == oldTransaction.category
    );
    
    if (index != -1) {
      current[index] = newTransaction;
      await _localStorageService.saveTransactions(current);
    }
  }

  // Get transactions within a date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate, 
    DateTime endDate
  ) async {
    final allTransactions = _localStorageService.getTransactions();
    return allTransactions?.where((t) => 
      t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
      t.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList() ?? [];
  }

  // Get total income
  Future<double> getTotalIncome() async {
    final allTransactions = _localStorageService.getTransactions();
    final inflow = allTransactions?.where((t) => t.amount > 0).toList() ?? [];
    return inflow.fold<double>(0.0, (double sum, transaction) => sum + transaction.amount);
  }

  // Get total expenses
  Future<double> getTotalExpenses() async {
    final allTransactions = _localStorageService.getTransactions();
    final outflow = allTransactions?.where((t) => t.amount < 0).toList() ?? [];
    return outflow.fold<double>(0.0, (double sum, transaction) => sum + transaction.amount.abs());
  }

  // Clear all transactions (useful for testing or reset)
  Future<void> clearAllTransactions() async {
    await _localStorageService.saveTransactions([]);
  }
}