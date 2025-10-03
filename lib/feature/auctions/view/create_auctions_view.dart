import 'dart:convert';
import 'package:alejandroloi/core/common/widgets/custom_image.dart';
import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/feature/auctions/controller/create_auctions_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../create_service/provider/auction_provider.dart';
import '../../service/view/service_view.dart';

class CreateAuctionsView extends StatefulWidget {
  CreateAuctionsView({super.key});

  @override
  State<CreateAuctionsView> createState() => _CreateAuctionsViewState();
}

class _CreateAuctionsViewState extends State<CreateAuctionsView> {
  final createAuctionsController = Get.put(CreateAuctionsController());

  int selectedValue = 0; // 1 = Public, 2 = Schedule
  int? _auctionMinutes;  // 10, 20, 30, 60

  // controllers
  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _startingBidCtrl = TextEditingController();
  final _shippingCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _descCtrl.dispose();
    _startingBidCtrl.dispose();
    _shippingCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
  String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final suffix = t.period == DayPeriod.am ? 'AM' : 'PM';
    return "$h:$m $suffix";
  }

  Future<void> _pickDate(BuildContext context) async {
    final p = context.read<AuctionProvider>();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 50),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
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
        _selectedDate = picked;
        _dateCtrl.text = _fmtDate(picked);
      });
      p.setSchedule(date: _dateCtrl.text.trim());
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final p = context.read<AuctionProvider>();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
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
      p.setSchedule(time: _timeCtrl.text.trim());
    }
  }

  void _toast(String title, String msg) {
    Get.snackbar(title, msg, backgroundColor: Colors.black87, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AuctionProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Images", style: bodyText1),
                  const Row(children: [ImagePickerSlot(), SizedBox(width: 15), ImagePickerSlot()]),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: CustomTextField(
                      controller: _titleCtrl,
                      hintText: "Enter your Auction title",
                      onChanged: p.setTitle,
                    ),
                  ),

                  Text("Category", style: bodyText1),
                  CustomTextField(
                    controller: _categoryCtrl,
                    hintText: 'Enter your Category Name',
                    onChanged: p.setCategory,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text("Description", style: bodyText1),
                  ),
                  Container(
                    decoration: BoxDecoration(color: AppColors.fieldColor, borderRadius: BorderRadius.circular(6)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _descCtrl,
                        textAlignVertical: TextAlignVertical.top,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 5,
                        onChanged: p.setDescription,
                        decoration: const InputDecoration(
                          hintText: "Describe your Auction in detail",
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Color(0xFFBFBFBF), fontWeight: FontWeight.w400, fontSize: 16),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text("Starting Bid", style: bodyText1),
                  ),
                  CustomTextField(
                    controller: _startingBidCtrl,
                    hintText: "Enter amount",
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    onChanged: p.setStartingBid,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text("Action Duration", style: bodyText1),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _DurationPill(
                          label: '10 minutes',
                          minutes: 10,
                          selectedMinutes: _auctionMinutes,
                          onTap: () {
                            setState(() => _auctionMinutes = 10);
                            p.setDurationMinutes(10);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DurationPill(
                          label: '20 minutes',
                          minutes: 20,
                          selectedMinutes: _auctionMinutes,
                          onTap: () {
                            setState(() => _auctionMinutes = 20);
                            p.setDurationMinutes(20);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _DurationPill(
                          label: '30 minutes',
                          minutes: 30,
                          selectedMinutes: _auctionMinutes,
                          onTap: () {
                            setState(() => _auctionMinutes = 30);
                            p.setDurationMinutes(30);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DurationPill(
                          label: '1 hour',
                          minutes: 60,
                          selectedMinutes: _auctionMinutes,
                          onTap: () {
                            setState(() => _auctionMinutes = 60);
                            p.setDurationMinutes(60);
                          },
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text("Shipping Details", style: bodyText1),
                  ),
                  Container(
                    decoration: BoxDecoration(color: AppColors.fieldColor, borderRadius: BorderRadius.circular(6)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _shippingCtrl,
                        maxLines: 10,
                        textAlignVertical: TextAlignVertical.top,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(color: Colors.white),
                        onChanged: p.setLocation, // reusing as location field
                        decoration: const InputDecoration(
                          hintText: "Describe shipping options, costs, and estimated delivery times",
                          hintStyle: TextStyle(color: Color(0xFFBFBFBF), fontWeight: FontWeight.w400, fontSize: 16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Column(
                    children: [
                      Row(
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.white),
                            child: Radio<int>(
                              value: 1,
                              groupValue: selectedValue,
                              onChanged: (value) => setState(() => selectedValue = value!),
                              activeColor: AppColors.bottomColor1,
                            ),
                          ),
                          const Text("Public", style: bodyText1),
                        ],
                      ),
                      Row(
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.white),
                            child: Radio<int>(
                              value: 2,
                              groupValue: selectedValue,
                              onChanged: (value) => setState(() => selectedValue = value!),
                              activeColor: AppColors.bottomColor1,
                            ),
                          ),
                          const Text("Schedule", style: bodyText1),
                        ],
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickDate(context),
                          child: AbsorbPointer(
                            child: CustomTextField(
                              controller: _dateCtrl,
                              hintText: "Date",
                              prefixIcon: Icons.calendar_today_outlined,
                              showBorder: true,
                              onChanged: (_) => p.setSchedule(date: _dateCtrl.text.trim()),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickTime(context),
                          child: AbsorbPointer(
                            child: CustomTextField(
                              controller: _timeCtrl,
                              hintText: "Time",
                              prefixIcon: Icons.watch_later_outlined,
                              showBorder: true,
                              onChanged: (_) => p.setSchedule(time: _timeCtrl.text.trim()),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: bottomWidget(
                      text: p.submitting ? "Creating..." : "Create Auctions",
                      onTap: p.submitting
                          ? null
                          : () async {
                        // Require date & time ALWAYS per your request
                        if (_dateCtrl.text.trim().isEmpty || _timeCtrl.text.trim().isEmpty) {
                          _toast('Missing info', 'Please select fields.');
                          return;
                        }

                        // push current text values into provider (just in case)
                        p
                          ..setTitle(_titleCtrl.text)
                          ..setCategory(_categoryCtrl.text)
                          ..setDescription(_descCtrl.text)
                          ..setStartingBid(_startingBidCtrl.text)
                          ..setLocation(_shippingCtrl.text)
                          ..setDurationMinutes(_auctionMinutes)
                          ..setSchedule(date: _dateCtrl.text, time: _timeCtrl.text);

                        final ok = await p.submit();
                        if (ok) {
                          Get.to(
                                () => const ServiceView(initialIndex: 2),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        } else if (p.error != null) {
                          _toast('Error', p.error!);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            if (p.submitting)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black.withOpacity(0.35),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DurationPill extends StatelessWidget {
  final String label;
  final int minutes;
  final int? selectedMinutes;
  final VoidCallback onTap;

  const _DurationPill({
    required this.label,
    required this.minutes,
    required this.selectedMinutes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = selectedMinutes == minutes;
    final Color border = selected ? const Color(0xFFFF8A34) : Colors.white24;
    final Color fill = selected ? const Color(0xFFFF8A34).withOpacity(0.12) : Colors.transparent;
    final Color text = selected ? const Color(0xFFFF8A34) : Colors.white70;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(Icons.watch_later_outlined, size: 18, color: text),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: text, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}


