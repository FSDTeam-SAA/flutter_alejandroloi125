import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ButtonState { idle, loading, done, error }

class ButtonController extends GetxController {
  var state = ButtonState.idle.obs;
  void setIdle() => state.value = ButtonState.idle;
  void setLoading() => state.value = ButtonState.loading;
  void setDone() => state.value = ButtonState.done;
  void setError() => state.value = ButtonState.error;
}

class CustomActionButton extends StatelessWidget {
  final Future<void> Function(ButtonController controller) onAction;
  final Future<void> Function()? onDone;
  final String idleText, loadingText, doneText, errorText;
  final double width, height, borderRadius;

  CustomActionButton({
    super.key,
    required this.onAction,
    this.onDone,
    this.idleText = "Save",
    this.loadingText = "Saving...",
    this.doneText = "Success",
    this.errorText = "Try Again",
    this.width = double.infinity,
    this.height = 45,
    this.borderRadius = 6,
  });

  final ButtonController controller = Get.put(ButtonController(), permanent: false);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.state.value;
      String text;Color bgColor;

      switch (state) {
        case ButtonState.loading:text = loadingText;bgColor = Color(0xFFFF4B3E);break;
        case ButtonState.done:text = doneText;bgColor = Color(0xFFFF4B3E);break;
        case ButtonState.error:text = errorText;bgColor = Color(0xFFFF4B3E);break;
        default:text = idleText;bgColor = const Color(0xFFFF4B3E);
      }

      return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(bgColor),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius),),
            ),
          ),
          onPressed: state == ButtonState.loading ? () {} : () async {
            controller.setLoading();
            await onAction(controller);
            if (controller.state.value == ButtonState.done && onDone != null) {await onDone!();}
          },
          child: state == ButtonState.loading ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,),)
              : Text(text, style: const TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.w500),),
        ),
      );
    });
  }
}


