import 'package:budgetbuddy_project/models/transaction_model.dart';
import 'package:budgetbuddy_project/services/local_storage_service.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';

//changed transaction to use TransactionModel
class TransactionServices {

  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  
  Future<List<TransactionModel>> getInflow() async {
    final allTransactions = _localStorageService.getTransactions();
    return allTransactions?.where((t) => t.amount == 0).toList() ?? [];
  }

  Future<List<TransactionModel>> getOutflow() async {
    final allTransactions = _localStorageService.getTransactions();
    return allTransactions?.where((t) => t.amount == 0).toList() ?? [];
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final current = _localStorageService.getTransactions() ?? [];
    await _localStorageService.saveTransactions([...current, transaction]);
  }

  Future<List<TransactionModel>> getTransactionByCategory(String category) async {
    final transactions = _localStorageService.getTransactions();
    return transactions?.where((t) => t.category == category).toList() ?? [];
  }
}
