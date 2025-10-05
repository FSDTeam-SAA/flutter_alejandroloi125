import 'package:alejandroloi/feature/splash/view/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import 'package:alejandroloi/core/network/api_service/api_client.dart';
import 'package:alejandroloi/core/network/api_service/token_store.dart';
import 'package:alejandroloi/feature/auth/repository/auth_repository.dart';
import 'package:alejandroloi/feature/auth/providers/auth_provider.dart';

import 'feature/auth/services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStore   = TokenStore();
  final apiClient    = ApiClient(tokenStore);
  final authService  = AuthService(apiClient);
  final authRepo     = AuthRepository(service: authService, tokenStore: tokenStore);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepo)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
