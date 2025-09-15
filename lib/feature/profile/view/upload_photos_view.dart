
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/images.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:flutter/material.dart';

class UploadPhotosView extends StatelessWidget {
  const UploadPhotosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.black,
      appBar: AppBar(centerTitle: true,
        leading: Icon(Icons.arrow_back,color: Colors.white,size: 30,),

        backgroundColor: Colors.transparent,
        title: Text("Upload Profile",style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("To create your new account, provide one of your photos.",style: text16,),
              SizedBox(height: 100,),
            Center(
              child: Container(height: 282,width:282,decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(282),
                border: Border.all(width: 5,color: AppColors.bottomColor1),

              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(Images.personIcon),),),
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Column(children: [
                Icon(Icons.camera_alt_outlined,color: Colors.white,size: 35,),
                Text("Camera",style: TextStyle(fontSize: 14,color: AppColors.bottomColor1,fontWeight: FontWeight.w400),),
              ],),SizedBox(width: 50,),
              Column(children: [
                Icon(Icons.image_outlined,color: Colors.white,size: 35,),
                Text("Photos",style: TextStyle(fontSize: 14,color: AppColors.bottomColor1,fontWeight: FontWeight.w400),),
              ],),
            ],)
            

          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Container(
            height: 51,width: 163,
            decoration: BoxDecoration( borderRadius: BorderRadius.circular(8),border: Border.all(width: 1,color: AppColors.bottomColor1)),
            child: Center(
              child: Text("Skip", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16,),
              ),),
          ),
            Container(height: 51, width: 163,
            decoration: BoxDecoration(color: AppColors.bottomColor1, borderRadius: BorderRadius.circular(8),),
            child: Center(
              child: Text("Continue", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16,),),
            ),
          ),
        ],)
      ),
    );
  }
}
