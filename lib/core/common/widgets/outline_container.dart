import 'package:alejandroloi/core/util/styles.dart';
import 'package:flutter/material.dart';

class CustomOutlineContainer extends StatelessWidget {
 final String ? image;
  final String?name;
  const   CustomOutlineContainer({super.key,this.image,this.name});

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: Colors.grey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('$image', height: 24, width: 24),
          const SizedBox(width: 15),
          Text(
       "$name",
            style: bodyText1.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
