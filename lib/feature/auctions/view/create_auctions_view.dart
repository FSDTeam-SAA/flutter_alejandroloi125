import 'package:alejandroloi/core/common/widgets/custom_image.dart';
import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/custom_warp.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/feature/auctions/controller/create_auctions_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auction_screen.dart';

class CreateAuctionsView extends StatefulWidget {
  CreateAuctionsView({super.key});

  @override
  State<CreateAuctionsView> createState() => _CreateAuctionsViewState();
}

class _CreateAuctionsViewState extends State<CreateAuctionsView> {
  final createAuctionsController = Get.put(CreateAuctionsController());

  int selectedValue = 0; // initial value

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
              Text("Images", style: bodyText1),
              Row(
                children: [
                  ImagePickerSlot(),
                  SizedBox(width: 15),
                  ImagePickerSlot(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: CustomTextField(hintText: "Enter your Investment title"),
              ),
              Text("Category", style: bodyText1),
              CustomWrapWidget(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: List.generate(
                  10,
                  (index) => Chip(
                    label: Text(
                      "Item $index",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Color(0xFF595959),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text("Description", style: bodyText1),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.fieldColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.top,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Describe your Investment in detail",
                      // helperText: "Optional: provide more details",
                      border: InputBorder.none,
                      hintStyle: const TextStyle(
                        color: Color(0xFFBFBFBF),
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text("Starting Bid", style: bodyText1),
              ),
              CustomTextField(
                hintText: "Enter amount",
                prefixIcon: Icons.attach_money,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text("Action Duration", style: bodyText1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomTextField(
                      hintText: "10 Minutes",
                      prefixIcon: Icons.watch_later_outlined,
                      showBorder: true,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: CustomTextField(
                      hintText: "20 Minutes",
                      prefixIcon: Icons.watch_later_outlined,
                      showBorder: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomTextField(
                      hintText: "30 Minutes",
                      prefixIcon: Icons.watch_later_outlined,
                      showBorder: true,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: CustomTextField(
                      hintText: "1 hour",
                      prefixIcon: Icons.watch_later_outlined,
                      showBorder: true,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text("Location", style: bodyText1),
              ),
              CustomTextField(
                hintText: "Enter Location",
                prefixIcon: Icons.location_on_outlined,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text("Shipping Details", style: bodyText1),
              ),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.fieldColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    maxLines: 10,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText:
                          "Describe shipping options, costs, and estimated delivery times",
                      hintStyle: const TextStyle(
                        color: Color(0xFFBFBFBF),
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomTextField(
                      hintText: "Date",
                      prefixIcon: Icons.calendar_today_outlined,
                      showBorder: true,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: CustomTextField(
                      hintText: "Time",
                      prefixIcon: Icons.watch_later_outlined,
                      showBorder: true,
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  Row(
                    children: [
                      Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(unselectedWidgetColor: Colors.white),
                        child: Radio<int>(
                          value: 1,
                          groupValue: selectedValue,
                          onChanged: (value) =>
                              setState(() => selectedValue = value!),
                          activeColor: AppColors.bottomColor1,
                        ),
                      ),
                      const Text("Public", style: bodyText1),
                    ],
                  ),
                  Row(
                    children: [
                      Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(unselectedWidgetColor: Colors.white),
                        child: Radio<int>(
                          value: 2, // unique value for option 2
                          groupValue: selectedValue,
                          onChanged: (value) =>
                              setState(() => selectedValue = value!),
                          activeColor: AppColors.bottomColor1,
                        ),
                      ),
                      const Text("Schedule", style: bodyText1),
                    ],
                  ),
                ],
              ),

              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 15),
              //   child: bottomWidget(text: "Create Auctions"),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: bottomWidget(
                  text: "Create Auctions",
                  onTap: () {
                    // Replace current page (no back)
                    Get.to(
                      () => const AuctionScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );

                    // Or keep back navigation:
                    // Get.to(() => const AuctionScreen(),
                    //   transition: Transition.rightToLeft,
                    //   duration: const Duration(milliseconds: 350),
                    //   curve: Curves.easeInOut,
                    // );
                  },
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
