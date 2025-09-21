import 'package:alejandroloi/core/common/widgets/custom_image.dart';
import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/custom_warp.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/feature/auctions/controller/create_auctions_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../service/view/service_view.dart';
// import 'auction_screen.dart'; // keep if you still use it elsewhere

class CreateAuctionsView extends StatefulWidget {
  CreateAuctionsView({super.key});

  @override
  State<CreateAuctionsView> createState() => _CreateAuctionsViewState();
}

class _CreateAuctionsViewState extends State<CreateAuctionsView> {
  final createAuctionsController = Get.put(CreateAuctionsController());

  int selectedValue = 0; // 1 = Public, 2 = Schedule

  // ---- Date & Time state ----
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();

  @override
  void dispose() {
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  // simple formatters (no extra packages)
  String _fmtDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
  String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final suffix = t.period == DayPeriod.am ? 'AM' : 'PM';
    return "$h:$m $suffix";
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 50),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        // Dark theme to match your UI
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.bottomColor1, // accent color
              surface: AppColors.fieldColor,   // field background
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = _fmtDate(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        // Dark theme to match your UI
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.bottomColor1,
              surface: AppColors.fieldColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeCtrl.text = _fmtTime(picked);
      });
    }
  }

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
                children: const [
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
                      (index) => const Chip(
                    label: Text(
                      "Item 0", // replace with your data source if needed
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
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.top,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Describe your Investment in detail",
                      border: InputBorder.none,
                      hintStyle: TextStyle(
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
              const CustomTextField(
                hintText: "Enter amount",
                prefixIcon: Icons.attach_money,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text("Action Duration", style: bodyText1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
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
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
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
              const CustomTextField(
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
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    maxLines: 10,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText:
                      "Describe shipping options, costs, and estimated delivery times",
                      hintStyle: TextStyle(
                        color: Color(0xFFBFBFBF),
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),



              // ---- Visibility / Schedule ----
              Column(
                children: [
                  Row(
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: Colors.white,
                        ),
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
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: Colors.white,
                        ),
                        child: Radio<int>(
                          value: 2,
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

              // ---- DATE & TIME FIELDS (tap to open pickers) ----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: CustomTextField(
                          controller: _dateCtrl,
                          hintText: "Date",
                          prefixIcon: Icons.calendar_today_outlined,
                          showBorder: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: AbsorbPointer(
                        child: CustomTextField(
                          controller: _timeCtrl,
                          hintText: "Time",
                          prefixIcon: Icons.watch_later_outlined,
                          showBorder: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ---- Bottom action ----
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: bottomWidget(
                  text: "Create Auctions",
                  onTap: () {
                    // Optional: basic validation for date & time
                    if (_selectedDate == null || _selectedTime == null) {
                      Get.snackbar(
                        'Missing info',
                        'Please select both date and time.',
                        backgroundColor: Colors.black87,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    // Navigate
                    Get.to(
                          () => const ServiceView(initialIndex: 2),
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
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

