import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';


class CommonFunctions {
  /// Spacing helper
  static SizedBox gap({double h = 0, double w = 0}) => SizedBox(height: h, width: w);

  /// Divider helper
  static Divider divider({Color? color, double thickness = 3, double height = 0}) {
    return Divider(
      color: color ?? Colors.grey.shade300,
      height: height,
      thickness: thickness,
    );
  }

  /// Success toast
  static void showSuccessToast({
    required BuildContext context,
    required String message,
    MotionToastPosition position = MotionToastPosition.top,
  }) {
    MotionToast.success(
      title: const Text('Success'),
      description: Text(message),
      // position: position,
    ).show(context);
  }

  /// Error toast
  static void showErrorToast({
    required BuildContext context,
    required String message,
    MotionToastPosition position = MotionToastPosition.top,
  }) {
    MotionToast.error(
      title: const Text('Error'),
      description: Text(message),
      // position: position,
    ).show(context);
  }

  /// Warning toast
  static void showWarningToast({
    required BuildContext context,
    required String message,
    MotionToastPosition position = MotionToastPosition.top,
  }) {
    MotionToast.warning(
      title: const Text('Oops!'),
      description: Text(message),
      // position: position,
    ).show(context);
  }


}

