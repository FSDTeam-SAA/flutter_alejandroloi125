import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/common/widgets/ster_text.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:flutter/material.dart';

class PersonalInfoAddView extends StatelessWidget {
  const PersonalInfoAddView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.black,
      appBar: AppBar(centerTitle: true,
        leading: Icon(Icons.arrow_back,color: Colors.white,size: 30,),


        backgroundColor: Colors.transparent,
        title: Text("Personal Information",style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("To create your new account, provide your information.",style: text16,),
            StarText(text: "Name"),
            CustomTextField(hintText: ""),
            StarText(text: "Age"),
            CustomTextField(hintText: ""),
            StarText(text: "Gender"),
            CustomTextField(hintText: ""),
            StarText(text: "Nationality"),
            CustomTextField(hintText: ""),
            StarText(text: "Address"),
            CustomTextField(hintText: ""),

          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 50),
        child: bottomWidget(text: "Continue"),
      ),
    );
  }
}
