import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import 'forget_password_view.dart';

class OtpCodeViewScreen extends StatelessWidget {
  final String email;
   OtpCodeViewScreen({super.key, required this.email});
final otpController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
        appBar: AppBar(centerTitle: true,
          leading: InkWell(onTap: (){Get.back();},
              child: Icon(Icons.arrow_back,color: Colors.white,size: 30,)),
          backgroundColor: Colors.transparent,
          title: Text("Enter Security code",style: TextStyle(color: Colors.white),),
        ),

      body:  Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text("Enter OTP",style: headingText,),
              Text("Please check your Email for a message with your code. Your code is 6 numbers long.", style: bodyText1.copyWith(color: Color(0xFFB5B7BA)),),
              Text(email,style: TextStyle(color: AppColors.bottomColor1,fontSize: 16),),
              SizedBox(height: 50,),
              Pinput(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                autofocus: true,
                length: 6,
                controller: otpController,

                defaultPinTheme: PinTheme(height: 52,width: 48, textStyle: TextStyle(fontSize: 20,
                  color: Colors.white, fontWeight: FontWeight.bold,),
                  decoration: BoxDecoration(
                    color: AppColors.fieldColor,

                    borderRadius: BorderRadius.circular(9),


                  ),
                ),
                /*submittedPinTheme: PinTheme(
                    height: 50,width: 55,

                    textStyle: TextStyle(fontSize: 18,color: AppColors.bottomColor1,fontWeight: FontWeight.w700),
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.bottomColor1,width: 1.5),
                        borderRadius: BorderRadius.circular(9)
                    )
                ),*/
                onCompleted: (pin) => print("Entered OTP: $pin"),
              ),

              const SizedBox(height: 15),Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Didn't get a code? ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => ForgetPasswordView());
                        //authController.sendOtp(); // resend OTP
                      },
                      child: Text("Resend", style: TextStyle(color: AppColors.bottomColor1, fontSize: 14, fontWeight: FontWeight.w400,),),
                    ),
                  ],
                ),
              ),
        bottomWidget(text: "Verify")




             ] ),
              )
    );

  }
}
