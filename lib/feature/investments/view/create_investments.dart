// lib/service/create_service/investment/create_investments_view.dart
import 'package:alejandroloi/core/common/widgets/custom_image.dart';
import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/custom_warp.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../create_service/provider/investment_provider.dart';
import '../../service/view/service_view.dart';

class CreateInvestmentsView extends StatelessWidget {
  const CreateInvestmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<InvestmentProvider>();
    final read = context.read<InvestmentProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: p.formKey,
            autovalidateMode: p.autovalidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Images', style: bodyText1),
                Row(
                  children: [
                    ImagePickerSlot(
                      onSelected: read.setImage, // wire to provider
                    ),
                    const SizedBox(width: 15),
                    const ImagePickerSlot(), // extra visual slot (not sent)
                  ],
                ),

                // Title
                const SizedBox(height: 15),
                Text('Investment Title', style: bodyText1),
                const SizedBox(height: 6),
                CustomTextField(
                  hintText: 'Enter your Investment title',
                  onChanged: read.setTitle,
                  validator: p.requiredTitle,
                ),

                // Category
                const SizedBox(height: 15),
                Text('Category', style: bodyText1),
                const SizedBox(height: 6),
                CustomTextField(
                  hintText: 'Enter your Category Name',
                  onChanged: read.setCategory,
                  validator: p.requiredCategory,
                ),
                const SizedBox(height: 8),


                // Description
                const SizedBox(height: 8),
                Text('Description', style: bodyText1),
                Container(
                  decoration: BoxDecoration(color: AppColors.fieldColor, borderRadius: BorderRadius.circular(6)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLines: 10,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        hintText: 'Describe your Investment in detail',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Color(0xFFBFBFBF), fontWeight: FontWeight.w400, fontSize: 16),
                      ),
                      onChanged: read.setDescription,
                      validator: p.requiredDesc,
                    ),
                  ),
                ),

                // Funding goal
                const SizedBox(height: 8),
                Text('Funding Goal', style: bodyText1),
                CustomTextField(
                  hintText: 'Enter amount',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  onChanged: read.setFundingGoal,
                  validator: (v) => p.numberRequired(v, 'Funding goal', min: 1),
                ),

                // Funding duration
                const SizedBox(height: 8),
                Text('Funding Duration', style: bodyText1),
                CustomTextField(
                  hintText: 'Number of day',
                  prefixIcon: Icons.watch_later_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: read.setDurationDays,
                  validator: (v) => p.numberRequired(v, 'Funding duration (days)', min: 1),
                ),

                // Location
                const SizedBox(height: 8),
                Text('Location', style: bodyText1),
                CustomTextField(
                  hintText: 'Enter Location',
                  prefixIcon: Icons.location_on_outlined,
                  onChanged: read.setLocation,
                  validator: p.requiredLocation,
                ),

                // Terms
                const SizedBox(height: 8),
                Text('Investment Terms', style: bodyText1),
                Container(
                  decoration: BoxDecoration(color: AppColors.fieldColor, borderRadius: BorderRadius.circular(6)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLines: 10,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        hintText: 'Describe the investment terms and potential returns.',
                        hintStyle: TextStyle(color: Color(0xFFBFBFBF), fontWeight: FontWeight.w400, fontSize: 16),
                        border: InputBorder.none,
                      ),
                      onChanged: read.setTerms,
                      validator: p.requiredTerms,
                    ),
                  ),
                ),

                // Submit
                const SizedBox(height: 15),
                bottomWidget(
                  text: p.submitting ? 'Creating...' : 'Create Investment',
                  onTap: p.submitting
                      ? null
                      : () async {
                    final ok = await read.submit();
                    if (ok) {
                      Get.off(
                            () => const ServiceView(),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                      Get.snackbar('Success', 'Investment created successfully',
                          snackPosition: SnackPosition.TOP);
                    } else {
                      final msg = read.error ?? 'Failed to create investment';
                      Get.snackbar('Error', msg, snackPosition: SnackPosition.TOP);
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// import 'package:alejandroloi/core/common/widgets/custom_image.dart';
// import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
// import 'package:alejandroloi/core/common/widgets/custom_warp.dart';
// import 'package:alejandroloi/core/common/widgets/save_botton.dart';
// import 'package:alejandroloi/core/util/app_colors.dart';
// import 'package:alejandroloi/core/util/styles.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:provider/provider.dart';
//
// import '../../create_service/provider/investment_provider.dart';
// import '../../service/view/my_investments/my_investments.dart';
// import '../../service/view/service_view.dart';
// import 'investment_screen.dart';
//
// class CreateInvestmentsView extends StatelessWidget {
//   const CreateInvestmentsView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final p = context.watch<InvestmentProvider>();
//     final read = context.read<InvestmentProvider>();
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Form(
//             key: p.formKey,
//             autovalidateMode: p.autovalidateMode,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Images",style: bodyText1,),
//                 Row(children: const [
//                   ImagePickerSlot(),
//                   SizedBox(width: 15),
//                   ImagePickerSlot(),
//                 ],
//                 ),
//
//                 // Title
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Investment Title', style: bodyText1),
//                       const SizedBox(height: 6),
//                       CustomTextField(
//                         hintText: "Enter your Investment title",
//                         onChanged: read.setTitle,
//                         validator: p.requiredTitle,
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 Text("Category", style: bodyText1,),
//
//                 // Category text input (optional)
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Text('Investment Title', style: bodyText1),
//                       const SizedBox(height: 6),
//                       CustomTextField(
//                         hintText: "Enter your Category Name",
//                         onChanged: read.setCategory,             // <-- fixed
//                         validator: p.requiredCategory,
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Or quick chips to set category
//                 CustomWrapWidget(
//                   spacing: 8,
//                   runSpacing: 8,
//                   alignment: WrapAlignment.start,
//                   children: List.generate(2, (index) {
//                     final c = 'Category $index';
//                     return GestureDetector(
//                       onTap: () => read.setCategory(c),
//                       child: Chip(
//                         label: Text(
//                           c,
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                         backgroundColor: const Color(0xFF595959),
//                       ),
//                     );
//                   }),
//                 ),
//
//
//
//
//                 // Description
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   child: Text("Description", style: bodyText1),
//                 ),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: AppColors.fieldColor,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: TextFormField(                     // <-- TextFormField
//                       maxLines: 10,
//                       textAlignVertical: TextAlignVertical.top,
//                       keyboardType: TextInputType.multiline,
//                       style: const TextStyle(color: Colors.white),
//                       cursorColor: Colors.white,
//                       decoration: const InputDecoration(
//                         hintText: "Describe your Investment in detail",
//                         border: InputBorder.none,
//                         hintStyle: TextStyle(
//                           color: Color(0xFFBFBFBF),
//                           fontWeight: FontWeight.w400,
//                           fontSize: 16,
//                         ),
//                       ),
//                       onChanged: read.setDescription,
//                       validator: p.requiredDesc,
//                     ),
//                   ),
//                 ),
//
//
//
//
//                 // Funding Goal
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   child: Text("Funding Goal",style: bodyText1,),
//                 ),
//                 CustomTextField(
//                   hintText: "Enter amount",
//                   prefixIcon: Icons.attach_money,
//                   // ✅ wire to provider
//                   keyboardType: TextInputType.number,
//                   onChanged: read.setFundingGoal,
//                   validator: (v) => p.numberRequired(v, 'Funding goal', min: 1),
//                 ),
//
//                 // Funding Duration
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   child: Text("Funding Duration",style: bodyText1,),
//                 ),
//                 CustomTextField(
//                   hintText: "Number of day",
//                   prefixIcon: Icons.watch_later_outlined,
//                   // ✅ wire to provider
//                   keyboardType: TextInputType.number,
//                   onChanged: read.setDurationDays,
//                   validator: (v) => p.numberRequired(v, 'Funding duration (days)', min: 1),
//                 ),
//
//                 // Location
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   child: Text("Location",style: bodyText1,),
//                 ),
//                 CustomTextField(
//                   hintText: "Enter Location",
//                   prefixIcon: Icons.location_on_outlined,
//                   // ✅ wire to provider
//                   onChanged: read.setLocation,
//                   validator: p.requiredLocation,
//
//                 ),
//
//                 // Terms
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   child: Text("Investment Terms",style: bodyText1,),
//                 ),
//
//
//
//                 Container(
//                   decoration: BoxDecoration(
//                       color: AppColors.fieldColor,
//                       borderRadius: BorderRadius.circular(6)
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: TextFormField(
//                       maxLines: 10,
//                       textAlignVertical: TextAlignVertical.top,
//                       keyboardType: TextInputType.multiline,
//                       style: const TextStyle(color: Colors.white),
//                       cursorColor: Colors.white,
//                       decoration: const InputDecoration(
//                         hintText: "Describe the investment terms and potential returns.",
//                         hintStyle: TextStyle(
//                           color: Color(0xFFBFBFBF),
//                           fontWeight: FontWeight.w400,
//                           fontSize: 16,
//                         ),
//                         border: InputBorder.none,
//                       ),
//                       // ✅ wire to provider
//                       onChanged: read.setTerms,
//                       validator: p.requiredTerms,
//                     ),
//                   ),
//                 ),
//
//                 // Submit
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   child: bottomWidget(
//                     text: p.submitting ? "Creating..." : "Create Investment",
//                     onTap: p.submitting
//                         ? null
//                         : () async {
//                       final ok = await read.submit();
//                       if (ok) {
//                         Get.off(() => const ServiceView(),
//                             transition: Transition.rightToLeft,
//                             duration: const Duration(milliseconds: 350),
//                             curve: Curves.easeInOut);
//                         Get.snackbar('Success', 'Investment created successfully',
//                             snackPosition: SnackPosition.TOP);
//                       } else {
//                         final msg = read.error ?? 'Failed to create investment';
//                         Get.snackbar('Error', msg,
//                             snackPosition: SnackPosition.TOP);
//                       }
//                     },
//                   ),
//                 ),
//
//
//                 const SizedBox(height: 10),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
