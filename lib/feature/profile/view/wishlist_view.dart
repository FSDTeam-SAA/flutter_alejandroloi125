import 'package:flutter/material.dart';

class WishlistScreenView extends StatelessWidget {
  const WishlistScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Wish List",style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.w700),),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,

      ),


    );
  }
}
