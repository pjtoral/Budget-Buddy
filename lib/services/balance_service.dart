import 'package:budgetbuddy_project/services/local_storage_service.dart';

class BalanceService {
  final LocalStorageService _localStorageService;

  BalanceService(this._localStorageService);

  Future<double> getBalance() async {
    return await _localStorageService.getBalance();
  }

  Future<void> updateBalance(double amount) async {
    final current = await getBalance();
    await _localStorageService.setBalance(current + amount);
  }

  Future<void> deductBalance(double amount) async {
    final current = await getBalance();
    if(amount > current) {
      throw Exception('You broke asf');
    }
    await _localStorageService.setBalance(current - amount);
  }
}
