import 'package:alejandroloi/core/common/widgets/custom_image.dart';
import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/custom_warp.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../service/view/my_investments/my_investments.dart';
import '../../service/view/service_view.dart';
import 'investment_screen.dart';

class CreateInvestmentsView extends StatelessWidget {
  const CreateInvestmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Images",style: bodyText1,),
             Row(children: [    ImagePickerSlot(),
               SizedBox(width: 15),
               ImagePickerSlot(),

          ],
               ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 15),
              //   child: CustomTextField(hintText: "Enter your Investment title"),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Investment Title', style: bodyText1),   // label
                    const SizedBox(height: 6),
                    CustomTextField(
                      hintText: "Enter your Investment title",

                    ),
                  ],
                ),
              ),

              Text("Category",style: bodyText1,),
              CustomWrapWidget(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: List.generate(
                  10, (index) => Chip(label: Text("Item $index",style: TextStyle(color: Colors.white),), backgroundColor: Color(0xFF595959),

                ),
                ),
              ),


              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text("Description",style: bodyText1,),
              ),
             Container(
                 decoration: BoxDecoration(
                     color: AppColors.fieldColor,
                     borderRadius: BorderRadius.circular(6)
                 ),
               child: Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: TextField(
                   textAlignVertical: TextAlignVertical.top,
                   keyboardType: TextInputType.multiline,
                   style: const TextStyle(color: Colors.white),     //  make text visible
                   cursorColor: Colors.white,
                   maxLines: 10,
                   decoration: InputDecoration(
                     hintText: "Describe your Investment in detail",
                    // helperText: "Optional: provide more details",
                     border: InputBorder.none,
                     hintStyle: const TextStyle(color: Color(0xFFBFBFBF), fontWeight: FontWeight.w400, fontSize: 16,),
                   ),
                 ),
               )

             ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text("Funding Goal",style: bodyText1,),
              ),
              CustomTextField(hintText: "Enter amount",prefixIcon: Icons.attach_money,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text("Funding Duration",style: bodyText1,),
              ),
              CustomTextField(hintText: "Number of day",prefixIcon: Icons.watch_later_outlined,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text("Location",style: bodyText1,),
              ),
              CustomTextField(hintText: "Enter Location",prefixIcon: Icons.location_on_outlined,),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text("Investment Terms",style: bodyText1,),
              ),

              Container(decoration: BoxDecoration(color: AppColors.fieldColor,borderRadius: BorderRadius.circular(6)),
                child: Padding(padding: const EdgeInsets.all(8.0),
                child: TextField(
                  maxLines: 10,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(color: Colors.white),     //  make text visible
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "Describe the investment terms and potential returns.",
                    hintStyle: const TextStyle(color: Color(0xFFBFBFBF), fontWeight: FontWeight.w400, fontSize: 16,),
                    border: InputBorder.none,
                  ),
                )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: bottomWidget(
                    text: "Create Investment",
                  onTap: () {
                    // If you want to replace this page:
                    Get.off(() => const ServiceView(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );


                  },
                ),
              ),
              SizedBox(height: 10,)
            ],
          ),
        )));



  }
}
