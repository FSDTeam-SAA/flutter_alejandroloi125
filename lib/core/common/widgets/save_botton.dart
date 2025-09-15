import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:flutter/material.dart';




Widget bottomWidget({required String text, VoidCallback? onTap}) {
  return InkWell(

    onTap: onTap,
    child: Container(
      height: 51,
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.bottomColor1, borderRadius: BorderRadius.circular(8),),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    ),
  );
}
