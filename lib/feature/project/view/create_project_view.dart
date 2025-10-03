import 'package:alejandroloi/core/common/widgets/custom_image.dart';
import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/custom_warp.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/feature/project/view/project.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../../create_service/provider/project_provider.dart';
import '../../service/view/service_view.dart';

class CreateProjectView extends StatelessWidget {
  const CreateProjectView({super.key});

  @override
  Widget build(BuildContext context) {

    final p = context.watch<ProjectProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: p.formKey,
          autovalidateMode: p.autovalidateMode,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Project Title", style: bodyText1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: CustomTextField(
                    hintText: "What Service do you need?",
                    onChanged: p.setTitle,
                    validator: p.requiredTitle,
                  ),
                ),
                Text("Category", style: bodyText1),
                CustomTextField(
                  hintText: 'Enter your Category Name',
                  onChanged: p.setCategory,
                  validator: p.requiredCategory,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text("Description", style: bodyText1),
                ),
                Container(
                  decoration: BoxDecoration(color: AppColors.fieldColor, borderRadius: BorderRadius.circular(6)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLines: 5,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(color: Colors.white),
                      onChanged: p.setDescription,
                      validator: p.requiredDesc,
                      decoration: const InputDecoration(
                        hintText: "Describe your Project in detail",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Color(0xFFBFBFBF), fontWeight: FontWeight.w400, fontSize: 16),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text("Budget Range", style: bodyText1),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        hintText: "Min",
                        prefixIcon: Icons.attach_money,
                        keyboardType: const TextInputType.numberWithOptions(decimal: false),
                        onChanged: p.setBudgetMin,
                        validator: (v) => p.numberRequired(v, 'Min budget', min: 0),
                        showBorder: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        hintText: "Max",
                        prefixIcon: Icons.attach_money,
                        keyboardType: const TextInputType.numberWithOptions(decimal: false),
                        onChanged: p.setBudgetMax,
                        validator: (v) => p.numberRequired(v, 'Max budget', min: 0),
                        showBorder: false,
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text("Deadline", style: bodyText1),
                ),
                CustomTextField(
                  hintText: "Number of day",
                  prefixIcon: Icons.watch_later_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  onChanged: p.setDurationDays,
                  validator: (v) => p.numberRequired(v, 'Deadline (days)', min: 1),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text("Location", style: bodyText1),
                ),
                CustomTextField(
                  hintText: "Enter Location",
                  prefixIcon: Icons.location_on_outlined,
                  onChanged: p.setLocation,
                  validator: p.requiredLocation,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text("Required Skills", style: bodyText1),
                ),
                CustomTextField(
                  hintText: "e.g. Web Design, App Development …",
                  prefixIcon: Icons.grid_view_rounded,
                  onChanged: p.setSkillsText,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: bottomWidget(
                    text: p.submitting ? "Creating..." : "Create Project Post",
                    onTap: () async {
                      if (p.submitting) return;
                      final ok = await context.read<ProjectProvider>().submit();
                      if (ok) {
                        Get.off(() => const ServiceView(initialIndex: 1),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut);
                      } else if (p.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(p.error!)),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );

    // return Scaffold(
    //     backgroundColor: Colors.black,
    //     body: Padding(
    //         padding: const EdgeInsets.all(16.0),
    //         child: SingleChildScrollView(
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text("Project Title",style: bodyText1,),
    //               Padding(
    //                 padding: const EdgeInsets.symmetric(vertical: 8),
    //                 child: CustomTextField(hintText: "What Service do you need?"),
    //               ),
    //               Text("Category",style: bodyText1,),
    //               // CustomWrapWidget(
    //               //   spacing: 8,
    //               //   runSpacing: 8,
    //               //   alignment: WrapAlignment.start,
    //               //   children: List.generate(
    //               //     10, (index) => Chip(label: Text("Item $index",style: TextStyle(color: Colors.white),), backgroundColor: Color(0xFF595959),
    //               //
    //               //   ),
    //               //   ),
    //               // ),
    //               CustomTextField(
    //                 hintText: 'Enter your Category Name',
    //                 // onChanged: read.setCategory,
    //                 // validator: p.requiredCategory,
    //               ),
    //
    //
    //               Padding(
    //                 padding: const EdgeInsets.symmetric(vertical: 8),
    //                 child: Text("Description",style: bodyText1,),
    //               ),
    //               Container(decoration: BoxDecoration(color: AppColors.fieldColor,borderRadius: BorderRadius.circular(6)),
    //                   child: Padding(
    //                     padding: const EdgeInsets.all(8.0),
    //                     child: TextField(
    //                       textAlignVertical: TextAlignVertical.top,
    //                       maxLines: 5,
    //                       decoration: InputDecoration(
    //                         hintText: "Describe your Investment in detail",
    //                         // helperText: "Optional: provide more details",
    //                         border: InputBorder.none,
    //                         hintStyle: const TextStyle(color: Color(0xFFBFBFBF), fontWeight: FontWeight.w400, fontSize: 16,),
    //                       ),
    //                     ),
    //                   )
    //
    //               ),
    //
    //
    //
    //
    //               // Padding(
    //               //   padding: const EdgeInsets.symmetric(vertical: 8),
    //               //   child: Text("Budget Range",style: bodyText1,),
    //               // ),
    //               // Row(
    //               //   children: [
    //               //
    //               //   ],
    //               // ),
    //
    //               Padding(
    //                 padding: const EdgeInsets.symmetric(vertical: 8),
    //                 child: Text("Budget Range", style: bodyText1),
    //               ),
    //               Row(
    //                 children: [
    //                   Expanded(
    //                     child: CustomTextField(
    //                       hintText: "Min",
    //                       prefixIcon: Icons.attach_money,
    //                       keyboardType: const TextInputType.numberWithOptions(decimal: true),
    //                       // filled: true,
    //                       // fillColor: AppColors.fieldColor,
    //                       // borderRadius: 8,
    //                       // contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    //                       showBorder: false,
    //                     ),
    //                   ),
    //                   const SizedBox(width: 12),
    //                   Expanded(
    //                     child: CustomTextField(
    //                       hintText: "Max",
    //                       prefixIcon: Icons.attach_money,
    //                       keyboardType: const TextInputType.numberWithOptions(decimal: true),
    //                       // filled: true,
    //                       // fillColor: AppColors.fieldColor,
    //                       // borderRadius: 8,
    //                       // contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    //                       showBorder: false,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //
    //
    //
    //               Padding(
    //                 padding: const EdgeInsets.symmetric(vertical: 8),
    //                 child: Text("Deadline",style: bodyText1,),
    //               ),
    //               CustomTextField(hintText: "Number of day",prefixIcon: Icons.watch_later_outlined,),
    //               Padding(
    //                 padding: const EdgeInsets.symmetric(vertical: 8),
    //                 child: Text("Location",style: bodyText1,),
    //               ),
    //               CustomTextField(hintText: "Enter Location",prefixIcon: Icons.location_on_outlined,),
    //
    //            Padding(
    //                 padding: const EdgeInsets.symmetric(vertical: 8),
    //                 child: Text("Required Skills",style: bodyText1,),
    //               ),
    //               CustomTextField(hintText: "e.g.web Design,App Development..",prefixIcon: Icons.location_on_outlined,),
    //
    //
    //
    //               Padding(
    //                 padding: const EdgeInsets.symmetric(vertical: 15),
    //                 child: bottomWidget(
    //                     text: "Create Project Post",
    //                   onTap: () {
    //                     Get.off(                               // replace current page
    //                           () => const ServiceView(initialIndex: 1),
    //                       transition: Transition.rightToLeft,
    //                       duration: const Duration(milliseconds: 350),
    //                       curve: Curves.easeInOut,
    //                     );
    //
    //                     // If you want to keep the current page in the stack, use:
    //                     // Get.to(() => const ProjectScreen(), transition: Transition.rightToLeft);
    //                   },
    //
    //                 ),
    //               ),
    //               SizedBox(height: 10,)
    //             ],
    //           ),
    //         )));
  }
}
