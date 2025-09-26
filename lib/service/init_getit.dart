import 'package:flutter/material.dart';
import 'api_service.dart';
import 'navigation_service.dart';
import 'package:get_it/get_it.dart';

// This is our global ServiceLocator
GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<ApiService>(() => ApiService());
}
