
import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

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
  body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(children: [
      CustomTextField(hintText: "New Password",isPassword: true,),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: CustomTextField(hintText: "Repeat New Password",isPassword: true,),
      ),

      bottomWidget(text: "Continue"),
    ],),
  ),

    );

  }
}
