// init_getit.dart
import 'package:get_it/get_it.dart';
import 'api_service.dart';
import 'navigation_service.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<ApiService>(() => ApiService());
}
