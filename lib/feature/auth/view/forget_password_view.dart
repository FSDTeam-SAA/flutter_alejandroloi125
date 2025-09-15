import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPasswordView extends StatelessWidget {
  const ForgetPasswordView({super.key});

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
            child: CustomTextField(prefixIcon: Icons.email_outlined,hintText: "Email",),
          ),
            bottomWidget(text: "Continue")



          ],
        ),
      ),
    );
  }
}
