import 'package:flutter/material.dart';

class LanguageScreenView extends StatelessWidget {
  const LanguageScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Language",style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.w700),),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,

      ),
    );
  }
}
