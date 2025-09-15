
import 'package:alejandroloi/core/util/images.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/feature/profile/view/about_view.dart';
import 'package:alejandroloi/feature/profile/view/change_password.dart';
import 'package:alejandroloi/feature/profile/view/language_view.dart';
import 'package:alejandroloi/feature/profile/view/personal_info_view.dart';
import 'package:alejandroloi/feature/profile/view/privacy_policy.dart';
import 'package:alejandroloi/feature/profile/view/terms_conditon.dart';
import 'package:alejandroloi/feature/profile/view/wishlist_view.dart';
import 'package:alejandroloi/feature/profile/widgets/top_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreenView extends StatelessWidget {
  const ProfileScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
    appBar: AppBar(

      title: Text("My Profile",style: headingText,),
      backgroundColor: Colors.transparent,

    ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(children: [
          
            Row(
              children: [
                CircleAvatar(radius: 30,backgroundColor: Colors.grey,),
                SizedBox(width: 10,),
                Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                  Text("Darelel Saerer",style: headingText,),
                  Text("addresss",style: bodyText1.copyWith(fontSize: 16),),
          
                ],),
              ],
            ),
          
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                topCard(imagePath: Images.currency,value: "8",type: "Investments"),
                topCard(imagePath: Images.layout,value: "14",type: "Project"),
                topCard(imagePath: Images.key,value: "22",type: "Action"),
          
              ],),
            ),
          
          
          
            profileBottom(imagePath: Images.credit,name: "Personal Information",voidCallBack: (){
              Get.to(()=>PersonalInfoView());
            }),
           profileBottom(imagePath: Images.wishlist,name: "WishList",voidCallBack: (){
             Get.to(()=>WishlistScreenView());
           }),
           profileBottom(imagePath: Images.lang,name: "Language",
               voidCallBack: (){
                 Get.to(()=>LanguageScreenView());
               }
           ),
           profileBottom(imagePath: Images.lock,name: "Change Password",
               voidCallBack: (){
                 Get.to(()=>ChangePasswordView());
               }
           ),
           profileBottom(imagePath: Images.about,name: "About App",voidCallBack: (){
             Get.to(()=>AboutView());
           }),
           profileBottom(imagePath: Images.privacy,name: "Privacy",
               voidCallBack: (){
                 Get.to(()=>PrivacyPolicyScreenView());
               }
           ),
           profileBottom(imagePath: Images.terms,name: "Term & Conditon",
               voidCallBack: (){
                 Get.to(()=>TermsConditionScreenView());
               }
           ),


            Container(decoration: BoxDecoration(border: Border.symmetric()),
              child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(children: [
                  Icon(Icons.logout,color: Colors.red,),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                      Text('Log Out',style: TextStyle(color: Colors.red,fontSize: 16,fontWeight: FontWeight.w600),),
                      Icon(Icons.arrow_forward_ios,color: Colors.red,)
                    ],),
                  )
                ],),
              ),
              Container(width: double.infinity,color: Colors.white,height: 1.5,)
            ],),
          ),

            SizedBox(height: 20,),
          ],),
        ),
      ),


    );
  }
}
