import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class PersonalInfoView extends StatelessWidget {
   PersonalInfoView({super.key});
final TextStyle typeStyle = TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w400,);
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Personal Information",style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.w700),),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text("Name",style: typeStyle,),
        ),
        CustomTextField(hintText: "e.g John Deo"),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text("Age",style: typeStyle,),
        ),
        CustomTextField(hintText: "e.g: 25"),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text("Gender",style: typeStyle,),
        ),
        CustomTextField(hintText: "e.g: Male"),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text("Nationality",style: typeStyle,),
        ),
        CustomTextField(hintText: "e.g: USA"),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text("Address",style: typeStyle,),
        ),
        CustomTextField(hintText: "e.g: LA"),

      ],),
    ),
    );
  }
}
