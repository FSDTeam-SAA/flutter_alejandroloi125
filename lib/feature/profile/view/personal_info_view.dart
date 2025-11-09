import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/language/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class PersonalInfoView extends StatefulWidget {
  PersonalInfoView({super.key});

  @override
  State<PersonalInfoView> createState() => _PersonalInfoViewState();
}

class _PersonalInfoViewState extends State<PersonalInfoView> {
  final TextStyle typeStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.w400,
  );

  @override
  Widget build(BuildContext context) {
    final languageController = Get.put(LanguageController());
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          languageController.t('personal_info'),
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(languageController.t('name'), style: typeStyle),
            ),
            CustomTextField(hintText: "e.g John Deo"),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(languageController.t('age'), style: typeStyle),
            ),
            CustomTextField(hintText: "e.g: 25"),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(languageController.t('gender'), style: typeStyle),
            ),
            CustomTextField(hintText: "e.g: Male"),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                languageController.t('nationality'),
                style: typeStyle,
              ),
            ),
            CustomTextField(hintText: "e.g: USA"),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(languageController.t("address"), style: typeStyle),
            ),
            CustomTextField(hintText: "e.g: LA"),
          ],
        ),
      ),
    );
  }
}
