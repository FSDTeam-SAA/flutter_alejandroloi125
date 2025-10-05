// lib/feature/project/view/create_project_view.dart
import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/feature/service/view/service_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateProjectView extends StatefulWidget {
  const CreateProjectView({super.key});

  @override
  State<CreateProjectView> createState() => _CreateProjectViewState();
}

class _CreateProjectViewState extends State<CreateProjectView> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _auto = AutovalidateMode.disabled;

  final _titleCtl = TextEditingController();
  final _categoryCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final _minBudgetCtl = TextEditingController();
  final _maxBudgetCtl = TextEditingController();
  final _durationCtl = TextEditingController();
  final _locationCtl = TextEditingController();
  final _skillsCtl = TextEditingController();

  @override
  void dispose() {
    _titleCtl.dispose();
    _categoryCtl.dispose();
    _descCtl.dispose();
    _minBudgetCtl.dispose();
    _maxBudgetCtl.dispose();
    _durationCtl.dispose();
    _locationCtl.dispose();
    _skillsCtl.dispose();
    super.dispose();
  }

  String? _required(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    return null;
  }

  String? _numberRequired(String? v, String label, {int min = 0}) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Enter a valid number';
    if (n < min) return '$label must be ≥ $min';
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState?.validate() ?? false;

    // Additional cross-field check: min ≤ max
    if (valid) {
      final minB = int.tryParse(_minBudgetCtl.text.trim()) ?? 0;
      final maxB = int.tryParse(_maxBudgetCtl.text.trim()) ?? 0;
      if (maxB > 0 && minB > maxB) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Max budget must be greater than or equal to Min budget')),
        );
        return;
      }

      Get.snackbar('Success', 'Project created (local only)',
          snackPosition: SnackPosition.TOP);

      Get.off(
            () => const ServiceView(initialIndex: 1),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() => _auto = AutovalidateMode.onUserInteraction);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors above')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: _auto,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Project Title", style: bodyText1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: CustomTextField(
                    hintText: "What Service do you need?",
                    controller: _titleCtl,
                    validator: (v) => _required(v, 'Title'),
                  ),
                ),

                Text("Category", style: bodyText1),
                CustomTextField(
                  hintText: 'Enter your Category Name',
                  controller: _categoryCtl,
                  validator: (v) => _required(v, 'Category'),
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
                    child: TextFormField(
                      controller: _descCtl,
                      maxLines: 5,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => _required(v, 'Description'),
                      decoration: const InputDecoration(
                        hintText: "Describe your Project in detail",
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
                  child: Text("Budget Range", style: bodyText1),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        hintText: "Min",
                        prefixIcon: Icons.attach_money,
                        keyboardType: const TextInputType.numberWithOptions(decimal: false),
                        controller: _minBudgetCtl,
                        validator: (v) => _numberRequired(v, 'Min budget', min: 0),
                        showBorder: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        hintText: "Max",
                        prefixIcon: Icons.attach_money,
                        keyboardType: const TextInputType.numberWithOptions(decimal: false),
                        controller: _maxBudgetCtl,
                        validator: (v) => _numberRequired(v, 'Max budget', min: 0),
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
                  controller: _durationCtl,
                  validator: (v) => _numberRequired(v, 'Deadline (days)', min: 1),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text("Location", style: bodyText1),
                ),
                CustomTextField(
                  hintText: "Enter Location",
                  prefixIcon: Icons.location_on_outlined,
                  controller: _locationCtl,
                  validator: (v) => _required(v, 'Location'),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text("Required Skills", style: bodyText1),
                ),
                CustomTextField(
                  hintText: "e.g. Web Design, App Development …",
                  prefixIcon: Icons.grid_view_rounded,
                  controller: _skillsCtl,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: bottomWidget(
                    text: "Create Project Post",
                    onTap: _submit,
                  ),
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
