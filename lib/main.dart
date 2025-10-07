// main.dart
import 'package:alejandroloi/providers/investment_provider.dart';
import 'package:alejandroloi/repository/investment_repository.dart';
import 'package:alejandroloi/services/investment_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'core/network/api_service/api_client.dart';
import 'core/network/api_service/token_store.dart';

import 'feature/auth/providers/auth_provider.dart';
import 'feature/auth/repository/auth_repository.dart';

import 'feature/auth/services/auth_service.dart';
import 'feature/profile/providers/profile_provider.dart';
import 'feature/profile/repository/profile_repository.dart';
import 'feature/profile/service/profile_service.dart';

import 'feature/splash/view/splash_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenStore>(create: (_) => TokenStore()),
        ProxyProvider<TokenStore, ApiClient>(
          update: (_, store, __) => ApiClient(store),
        ),

        // Auth stack
        ProxyProvider<ApiClient, AuthService>(
          update: (_, client, __) => AuthService(client),
        ),
        ProxyProvider2<AuthService, TokenStore, AuthRepository>(
          update: (_, svc, store, __) =>
              AuthRepository(service: svc, tokenStore: store),
        ),
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(ctx.read<AuthRepository>()),
        ),

        // Profile stack (uses SAME ApiClient)
        ProxyProvider<ApiClient, ProfileService>(
          update: (_, client, __) => ProfileService(client),
        ),
        ProxyProvider<ProfileService, ProfileRepository>(
          update: (_, svc, __) => ProfileRepository(svc),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ProfileProvider(ctx.read<ProfileRepository>()),
        ),

        // ---- investment stack (uses THE SAME ApiClient) ----
        ProxyProvider<ApiClient, InvestmentService>(
          update: (_, client, __) => InvestmentService(client),
        ),
        ProxyProvider<InvestmentService, InvestmentRepository>(
          update: (_, svc, __) => InvestmentRepository(svc),
        ),
        ChangeNotifierProvider(
          create: (ctx) => InvestmentProvider(ctx.read<InvestmentRepository>()),
        ),

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


// import 'package:alejandroloi/feature/splash/view/splash_view.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:get/get.dart';
//
// import 'package:alejandroloi/core/network/api_service/api_client.dart';
// import 'package:alejandroloi/core/network/api_service/token_store.dart';
// import 'package:alejandroloi/feature/auth/repository/auth_repository.dart';
// import 'package:alejandroloi/feature/auth/providers/auth_provider.dart';
//
// import 'feature/auth/services/auth_service.dart';
//
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   final tokenStore   = TokenStore();
//   final apiClient    = ApiClient(tokenStore);
//   final authService  = AuthService(apiClient);
//   final authRepo     = AuthRepository(service: authService, tokenStore: tokenStore);
//
//   runApp(
//     MultiProvider(
//       providers: [
//
//         ChangeNotifierProvider(create: (_) => AuthProvider(authRepo)),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const SplashScreen(),
//     );
//   }
// }
