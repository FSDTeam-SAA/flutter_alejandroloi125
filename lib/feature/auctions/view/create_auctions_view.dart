// lib/feature/auction/view/create_auctions_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:alejandroloi/core/common/widgets/custom_image.dart';
import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/styles.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../providers/auction_provider.dart';
import '../../app_ground.dart';
import '../../models/auction.dart';

class CreateAuctionsView extends StatefulWidget {
  const CreateAuctionsView({super.key});

  @override
  State<CreateAuctionsView> createState() => _CreateAuctionsViewState();
}

class _CreateAuctionsViewState extends State<CreateAuctionsView> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _auto = AutovalidateMode.disabled;

  int? _auctionMinutes; // 10, 20, 30, 60
  bool _submitting = false;

  File? _image;
  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _startingBidCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
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
    _locationCtrl.dispose();
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.bottomColor1,
            surface: AppColors.fieldColor,
            onSurface: Colors.white,
          ), dialogTheme: DialogThemeData(backgroundColor: Colors.black),
        ),
        child: child!,
      ),
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
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.bottomColor1,
            surface: AppColors.fieldColor,
            onSurface: Colors.white,
          ), dialogTheme: DialogThemeData(backgroundColor: Colors.black),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeCtrl.text = _fmtTime(picked);
      });
    }
  }

  String _durationLabel() {
    switch (_auctionMinutes) {
      case 10:
        return '10m';
      case 20:
        return '20m';
      case 30:
        return '30m';
      case 60:
        return '1h';
    }
    return '';
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) {
      setState(() => _auto = AutovalidateMode.onUserInteraction);
      Get.snackbar('Fix errors', 'Please correct the highlighted fields',
          snackPosition: SnackPosition.TOP);
      return;
    }
    if (_image == null) {
      Get.snackbar('Image required', 'Please add a photo',
          snackPosition: SnackPosition.TOP);
      return;
    }
    if (_auctionMinutes == null) {
      Get.snackbar('Duration required', 'Please choose a duration',
          snackPosition: SnackPosition.TOP);
      return;
    }

    // Split comma-separated categories into a list
    final categories = _categoryCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (categories.isEmpty) categories.add('general');

    final req = AuctionCreateRequest(
      name: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: categories,
      startingBid: int.parse(_startingBidCtrl.text.trim()),
      duration: _auctionMinutes!, // minutes (Number)
      location: _locationCtrl.text.trim(),
      date: _dateCtrl.text.trim(),
      time: _timeCtrl.text.trim(),
      imagePath: _image!.path, // required
    );

    setState(() => _submitting = true);
    try {
      final prov = context.read<AuctionProvider>();
      final res = await prov.createAuction(req);

      Get.offAll(
            () => const AppGround(initialIndex: 1, servicesInitialTab: 2),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      Get.snackbar('Success', res.message, snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Failed', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _req(String? v, String name) =>
      (v == null || v.trim().isEmpty) ? '$name is required' : null;

  String? _numReq(String? v, String name) {
    if (v == null || v.trim().isEmpty) return '$name is required';
    final n = int.tryParse(v);
    if (n == null || n <= 0) return '$name must be > 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: _auto,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Images", style: bodyText1),
                Row(
                  children: [
                    ImagePickerSlot(
                      onSelected: (val) {
                        if (val == null) return;
                        setState(() => _image = val);
                                            },
                    ),
                    const SizedBox(width: 15),
                    const ImagePickerSlot(),
                  ],
                ),

                const SizedBox(height: 15),
                CustomTextField(
                  controller: _titleCtrl,
                  hintText: "Enter your Auction title",
                  validator: (v) => _req(v, 'Title'),
                ),

                const SizedBox(height: 10),
                Text("Category", style: bodyText1),
                CustomTextField(
                  controller: _categoryCtrl,
                  hintText: 'Enter your Category Name (comma separated for multiple)',
                  validator: (v) => _req(v, 'Category'),
                ),

                const SizedBox(height: 8),
                Text("Description", style: bodyText1),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.fieldColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _descCtrl,
                      maxLines: 5,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Describe your Auction in detail",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Color(0xFFBFBFBF),
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                      validator: (v) => _req(v, 'Description'),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Text("Starting Bid", style: bodyText1),
                CustomTextField(
                  controller: _startingBidCtrl,
                  hintText: "Enter amount",
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (v) => _numReq(v, 'Starting bid'),
                ),

                const SizedBox(height: 8),
                Text("Auction Duration", style: bodyText1),
                Row(
                  children: [
                    Expanded(
                      child: _DurationPill(
                        label: '10 minutes',
                        minutes: 10,
                        selectedMinutes: _auctionMinutes,
                        onTap: () => setState(() => _auctionMinutes = 10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DurationPill(
                        label: '20 minutes',
                        minutes: 20,
                        selectedMinutes: _auctionMinutes,
                        onTap: () => setState(() => _auctionMinutes = 20),
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
                        onTap: () => setState(() => _auctionMinutes = 30),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DurationPill(
                        label: '1 hour',
                        minutes: 60,
                        selectedMinutes: _auctionMinutes,
                        onTap: () => setState(() => _auctionMinutes = 60),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Text("Location", style: bodyText1),
                CustomTextField(
                  controller: _locationCtrl,
                  hintText: "Enter location",
                  prefixIcon: Icons.location_on_outlined,
                  validator: (v) => _req(v, 'Location'),
                ),

                const SizedBox(height: 10),
                Row(
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
                            validator: (v) => _req(v, 'Date'),
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
                            validator: (v) => _req(v, 'Time'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                bottomWidget(
                  text: _submitting ? "Creating..." : "Create Auctions",
                  onTap: _submitting ? null : _submit,
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
    final selected = selectedMinutes == minutes;
    final border = selected ? const Color(0xFFFF8A34) : Colors.white24;
    final fill =
    selected ? const Color(0xFFFF8A34).withOpacity(0.12) : Colors.transparent;
    final text = selected ? const Color(0xFFFF8A34) : Colors.white70;

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
            Text(
              label,
              style: TextStyle(color: text, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
