import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'service/init_getit.dart';
import 'service/navigation_service.dart';
import 'service/api_service.dart';
import 'feature/auth/services/auth_repository.dart';
import 'feature/auth/controllers/auth_provider.dart';
import 'feature/auth/controllers/onboarding_provider.dart';
import 'feature/splash/view/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await dotenv.load(fileName: 'assets/.env');
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        ChangeNotifierProvider(create: (_) => AuthProvider()..loadSession()),

        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
          systemStatusBarContrastEnforced: false,
        ),
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nver App',
          theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
          navigatorKey: getIt<NavigationService>().navigatorKey,
          home: const SplashScreen(),
        ),
      ),
    );
  }

}
