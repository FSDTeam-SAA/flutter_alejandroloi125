import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'otp_code_view.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {

  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _goToOtp() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar('Email required', 'Please enter your email');
      return;
    }
    // push OTP screen (use Get.off if you don't want to return to Forgot)
    Get.to(() => OtpCodeViewScreen(email: email),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    // or: Get.off(() => OtpCodeViewScreen(email: email));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor:Colors.black,
      appBar: AppBar(centerTitle: true,
        leading: InkWell(
            onTap: (){Get.back();},
            child: Icon(Icons.arrow_back,color: Colors.white,size: 30,)),

        backgroundColor: Colors.transparent,
        title: Text("Forgot Password",style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select which contact details should we use to reset your password",style: text16,),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: CustomTextField(prefixIcon: Icons.email_outlined,hintText: "Email",controller: emailController,),
          ),
            // bottomWidget(text: "Continue")

            GestureDetector(onTap: _goToOtp, child: bottomWidget(text: "Continue")),



          ],
        ),
      ),
    );
  }
}
