import 'package:budgetbuddy_project/services/local_storage_service.dart';
import 'package:get_it/get_it.dart';

 final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<LocalStorageService>(() => LocalStorageService());

}