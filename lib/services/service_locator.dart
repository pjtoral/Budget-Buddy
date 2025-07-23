import 'package:budgetbuddy_project/services/balance_service.dart';
import 'package:budgetbuddy_project/services/local_storage_service.dart';
import 'package:budgetbuddy_project/services/transaction_services.dart';
import 'package:get_it/get_it.dart';

 final GetIt locator = GetIt.instance;

  Future<void> setupLocator() async {
  //added BalanceService and TransactionServices

  await LocalStorageService.init();

  locator.registerLazySingleton<LocalStorageService>(() => LocalStorageService());
  locator.registerLazySingleton<BalanceService>(() => BalanceService(locator<LocalStorageService>()));
  locator.registerLazySingleton<TransactionServices>(() => TransactionServices());
}