
import 'package:alejandroloi/core/util/app_colors.dart';

import 'package:flutter/material.dart';

Widget topCard({required String value,required String type,required String imagePath}){
  return Container(width: 109,
    decoration: BoxDecoration(color: AppColors.fieldColor,
    borderRadius: BorderRadius.circular(6),),

    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Image.asset(imagePath,height: 20,width: 20,),
            SizedBox(width: 8,),
            Text(value,style: TextStyle(fontSize: 24,fontWeight: FontWeight.w700,color: Colors.white),),
          ],),
          Text(type,style: TextStyle(fontWeight: FontWeight.w600,color: Color(0xFFA8A8A8),fontSize: 14),)
        ],
      ),
    ),

  );
}


  Widget profileBottom({required String name,required String imagePath,voidCallBack

}){
  return InkWell(
    onTap: voidCallBack,
    child: Container(
      decoration: BoxDecoration(
        border: Border.symmetric()
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(children: [
            Image.asset(imagePath,height: 25,width: 25,),
            SizedBox(width: 10,),
            Expanded(
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                Text(name,style: TextStyle(color: Color(0xFFE0E0E0,),fontSize: 16,fontWeight: FontWeight.w600),),
                Icon(Icons.arrow_forward_ios,color: Colors.white,)
              ],),
            )
          ],),
        ),
    Container(width: double.infinity,color: Colors.white,height: 1.5,)
      ],),
    ),
  );
}
