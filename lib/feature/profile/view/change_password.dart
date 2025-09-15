import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:flutter/material.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(     backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Change Password",style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.w700),),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body:Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          CustomTextField(hintText: "Current Password"),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: CustomTextField(hintText: "New Password"),
          ),
          CustomTextField(hintText: "Confirm Password"),
          
          SizedBox(height: 30,),
          bottomWidget(text: "Save")
          
        ],),
      ),
    );
  }
}
