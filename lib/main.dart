// main.dart
import 'package:alejandroloi/core/env/env.dart';
import 'package:alejandroloi/providers/auction_provider.dart';
import 'package:alejandroloi/providers/investment_provider.dart';
import 'package:alejandroloi/providers/project_provider.dart';
import 'package:alejandroloi/repository/auction_repository.dart';
import 'package:alejandroloi/repository/investment_repository.dart';
import 'package:alejandroloi/repository/project_repository.dart';
import 'package:alejandroloi/services/auction_service.dart';
import 'package:alejandroloi/services/investment_service.dart';
import 'package:alejandroloi/services/project_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'core/network/api_service/api_client.dart';
import 'core/network/api_service/app_di.dart';
import 'core/network/api_service/token_store.dart';

import 'core/network/payment_service.dart';
import 'feature/auth/providers/auth_provider.dart';
import 'feature/auth/repository/auth_repository.dart';

import 'feature/auth/services/auth_service.dart';
import 'feature/investments/providers/investment_detail_provider.dart';
import 'feature/profile/providers/profile_provider.dart';
import 'feature/profile/repository/profile_repository.dart';
import 'feature/profile/service/profile_service.dart';

import 'feature/splash/view/splash_view.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = AppEnv.stripePublishableKey;   // pk_live_xxx / pk_test_xxx
  Stripe.merchantIdentifier = 'merchant.com.your.bundle';
  await Stripe.instance.applySettings();





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

        // Investment stack
        ProxyProvider<ApiClient, InvestmentService>(
          update: (_, client, __) => InvestmentService(client),
        ),
        ProxyProvider<InvestmentService, InvestmentRepository>(
          update: (_, svc, __) => InvestmentRepository(svc),
        ),
        ChangeNotifierProvider(
          create: (ctx) => InvestmentProvider(ctx.read<InvestmentRepository>()),
        ),



        // ========= PROJECT STACK (mirror of Investment) =========
        ProxyProvider<ApiClient, ProjectService>(
          update: (_, client, __) => ProjectService(client),
        ),
        ProxyProvider<ProjectService, ProjectRepository>(
          update: (_, svc, __) => ProjectRepository(svc),
        ),
        ChangeNotifierProvider<ProjectProvider>(
          create: (ctx) => ProjectProvider(ctx.read<ProjectRepository>()),
        ),

        //auction
        ProxyProvider<ApiClient, AuctionService>(
          update: (_, client, __) => AuctionService(client),
        ),
        ProxyProvider<AuctionService, AuctionRepository>(
          update: (_, svc, __) => AuctionRepository(svc),
        ),
        ChangeNotifierProvider<AuctionProvider>(
          create: (ctx) => AuctionProvider(ctx.read<AuctionRepository>()),
        ),

        ProxyProvider<ApiClient, PaymentService>(
          update: (_, client, __) => PaymentService(client.dio),
        ),

        ChangeNotifierProvider(create: (_) => InvestmentDetailProvider(AppDI.investmentRepo())),














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


