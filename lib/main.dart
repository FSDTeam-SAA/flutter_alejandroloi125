

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


import 'feature/splash/view/splash_view.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();


  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
          systemStatusBarContrastEnforced: false,
        ),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',

        theme: ThemeData(

          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),


        home: SplashScreen(),
        // home: WishlistViewScreen(),

      ),
    );
  }
}
