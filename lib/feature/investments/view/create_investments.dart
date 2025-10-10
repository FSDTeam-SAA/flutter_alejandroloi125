import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:alejandroloi/core/common/widgets/custom_image.dart';     // ImagePickerSlot
import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';      // bottomWidget
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/styles.dart';

import '../../../providers/investment_provider.dart';
import '../../app_ground.dart';
// your existing screen

// inside _CreateInvestmentsViewState
import 'dart:io';
import 'package:provider/provider.dart';

class CreateInvestmentsView extends StatefulWidget {
  const CreateInvestmentsView({super.key});

  @override
  State<CreateInvestmentsView> createState() => _CreateInvestmentsViewState();
}

class _CreateInvestmentsViewState extends State<CreateInvestmentsView> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _auto = AutovalidateMode.disabled;
  bool _submitting = false;

  // Local fields
  dynamic _image; // keep dynamic since ImagePickerSlot's type may vary (File/XFile/String)
  String _title = '';
  String _category = '';
  String _desc = '';
  String _fundingGoal = '';
  String _durationDays = '';
  String _location = '';
  String _terms = '';

  // ---------- Validators ----------
  String? _requiredField(String? v, String name) {
    if (v == null || v.trim().isEmpty) return '$name is required';
    return null;
  }

  String? _numberRequired(String? v, String name, {num min = 0}) {
    if (v == null || v.trim().isEmpty) return '$name is required';
    final n = num.tryParse(v);
    if (n == null) return 'Enter a valid number for $name';
    if (n < min) return '$name must be at least $min';
    return null;
  }



  Future<void> _submit() async {
    final okForm = _formKey.currentState?.validate() ?? false;
    if (!okForm) {
      setState(() => _auto = AutovalidateMode.onUserInteraction);
      Get.snackbar('Fix errors', 'Please correct the highlighted fields', snackPosition: SnackPosition.TOP);
      return;
    }
    if (_submitting) return;
    setState(() => _submitting = true);

    final inv = context.read<InvestmentProvider>();

    // Convert dynamic image to File (supports File or XFile)
    File? asFile;
    if (_image is File) {
      asFile = _image as File;
    } else if (_image != null && _image.path != null) {
      asFile = File(_image.path); // XFile
    }

    final created = await inv.create(
      name: _title.trim(),
      description: _desc.trim(),
      category: _category.trim(),
      fundingGoalStr: _fundingGoal.trim(),
      durationDaysStr: _durationDays.trim(),
      location: _location.trim(),
      investmentTerms: _terms.trim(),
      imageFile: asFile!, // provider will validate null and show error
    );

    setState(() => _submitting = false);

    if (!mounted) return;
    if (created) {
      Get.back(result: true);

      Get.snackbar('Success', 'Investment created successfully', snackPosition: SnackPosition.TOP);

      // RIGHT: go to AppGround, select Services bottom tab + Investments inner tab
      Get.offAll(
            () => const AppGround(
          initialIndex: 1,        // bottom bar: 0=Home, 1=Services, 2=Event, 3=Profile
          servicesInitialTab: 0,  // ServiceView's pills: 0=Investments, 1=Project, 2=Auctions
        ),
        transition: Transition.rightToLeft,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );

    } else {
      Get.snackbar('Error', inv.error ?? 'Create failed', snackPosition: SnackPosition.TOP);
    }
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
                Text('Images', style: bodyText1),
                Row(
                  children: [
                    ImagePickerSlot(
                      onSelected: (val) => setState(() => _image = val),
                    ),
                    const SizedBox(width: 15),
                    const ImagePickerSlot(), // extra visual slot (not submitted)
                  ],
                ),

                const SizedBox(height: 15),
                Text('Investment Title', style: bodyText1),
                const SizedBox(height: 6),
                CustomTextField(
                  hintText: 'Enter your Investment title',
                  onChanged: (v) => _title = v,
                  validator: (v) => _requiredField(v, 'Title'),
                ),

                const SizedBox(height: 15),
                Text('Category', style: bodyText1),
                const SizedBox(height: 6),
                CustomTextField(
                  hintText: 'Enter your Category Name',
                  onChanged: (v) => _category = v,
                  validator: (v) => _requiredField(v, 'Category'),
                ),

                const SizedBox(height: 8),
                Text('Description', style: bodyText1),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.fieldColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
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
                        hintStyle: TextStyle(
                          color: Color(0xFFBFBFBF),
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                      onChanged: (v) => _desc = v,
                      validator: (v) => _requiredField(v, 'Description'),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Text('Funding Goal', style: bodyText1),
                CustomTextField(
                  hintText: 'Enter amount',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _fundingGoal = v,
                  validator: (v) => _numberRequired(v, 'Funding goal', min: 1),
                ),

                const SizedBox(height: 8),
                Text('Funding Duration', style: bodyText1),
                CustomTextField(
                  hintText: 'Number of day',
                  prefixIcon: Icons.watch_later_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _durationDays = v,
                  validator: (v) => _numberRequired(v, 'Funding duration (days)', min: 1),
                ),

                const SizedBox(height: 8),
                Text('Location', style: bodyText1),
                CustomTextField(
                  hintText: 'Enter Location',
                  prefixIcon: Icons.location_on_outlined,
                  onChanged: (v) => _location = v,
                  validator: (v) => _requiredField(v, 'Location'),
                ),

                const SizedBox(height: 8),
                Text('Investment Terms', style: bodyText1),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.fieldColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLines: 10,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        hintText:
                        'Describe the investment terms and potential returns.',
                        hintStyle: TextStyle(
                          color: Color(0xFFBFBFBF),
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (v) => _terms = v,
                      validator: (v) => _requiredField(v, 'Investment terms'),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                bottomWidget(
                  text: _submitting ? 'Creating...' : 'Create Investment',
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
