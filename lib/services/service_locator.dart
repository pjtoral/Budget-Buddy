import 'package:budgetbuddy_project/services/balance_service.dart';
import 'package:budgetbuddy_project/services/local_storage_service.dart';
import 'package:budgetbuddy_project/services/transaction_services.dart';
import 'package:budgetbuddy_project/services/category_service.dart';
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  await LocalStorageService.init();

  locator.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(),
  );
  locator.registerLazySingleton<BalanceService>(() => BalanceService());
  locator.registerLazySingleton<TransactionServices>(
    () => TransactionServices(),
  );
  locator.registerLazySingleton<CategoryService>(() => CategoryService());
}
