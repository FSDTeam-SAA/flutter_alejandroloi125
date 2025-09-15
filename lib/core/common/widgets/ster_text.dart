import 'package:flutter/material.dart';

class StarText extends StatelessWidget {
  final String text;

  const StarText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Text(text, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w400,),),
          Positioned(
            top: -5,
            right: -10,
            child: const Text("*", style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold,),),
          ),
        ],
      ),
    );
  }
}
