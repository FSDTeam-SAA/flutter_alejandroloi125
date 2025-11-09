// lib/feature/project/view/create_project_view.dart
import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../core/language/language_controller.dart';
import '../../../providers/project_provider.dart';
import '../../app_ground.dart';

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

  // inside _CreateProjectViewState
  bool _submitting = false;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      setState(() => _auto = AutovalidateMode.onUserInteraction);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Please fix the errors above')),
      // );

      Get.snackbar(
        backgroundColor: Colors.white,
        colorText: Colors.black,
        'Success',
        'Please fix the errors above',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (_submitting) return;
    setState(() => _submitting = true);

    final prov = context.read<ProjectProvider>();
    final ok = await prov.create(
      title: _titleCtl.text,
      description: _descCtl.text,
      category: _categoryCtl.text,
      minBudgetStr: _minBudgetCtl.text,
      maxBudgetStr: _maxBudgetCtl.text,
      deadlineDaysStr: _durationCtl.text,
      location: _locationCtl.text,
      skillsCsv: _skillsCtl.text, // comma-separated from UI
    );

    setState(() => _submitting = false);

    if (!mounted) return;

    if (ok) {
      Get.snackbar(
        backgroundColor: Colors.white,
        colorText: Colors.black,
        'Success',
        'Project created successfully',
        snackPosition: SnackPosition.TOP,
      );

      // Go to bottom-tab "Services" and the inner "Project" tab selected
      Get.offAll(
        () => const AppGround(initialIndex: 1, servicesInitialTab: 1),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      final err = prov.error ?? 'Create failed';
      Get.snackbar(
        backgroundColor: Colors.white,
        colorText: Colors.black,

        'Error',
        err,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final langController = Get.put(LanguageController());
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
                Text(langController.t('project_title'), style: bodyText1),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CustomTextField(
                    hintText: langController.t('enter_project_title'),
                    controller: _titleCtl,
                    validator: (v) => _required(v, 'Title'),
                  ),
                ),

                Text(langController.t('category'), style: bodyText1),
                CustomTextField(
                  hintText: langController.t('enter_category'),
                  controller: _categoryCtl,
                  validator: (v) => _required(v, 'Category'),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    langController.t('description'),
                    style: bodyText1,
                  ),
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
                      decoration: InputDecoration(
                        hintText: langController.t('entert_description'),
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
                  child: Text(
                    langController.t('budget_range'),
                    style: bodyText1,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        hintText: langController.t('min'),
                        prefixIcon: Icons.attach_money,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        controller: _minBudgetCtl,
                        validator: (v) =>
                            _numberRequired(v, 'Min budget', min: 0),
                        showBorder: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        hintText: langController.t('max'),
                        prefixIcon: Icons.attach_money,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        controller: _maxBudgetCtl,
                        validator: (v) =>
                            _numberRequired(v, 'Max budget', min: 0),
                        showBorder: false,
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(langController.t('deadline'), style: bodyText1),
                ),
                CustomTextField(
                  hintText: langController.t('number_of_days'),
                  prefixIcon: Icons.watch_later_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                  controller: _durationCtl,
                  validator: (v) =>
                      _numberRequired(v, 'Deadline (days)', min: 1),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(langController.t('location'), style: bodyText1),
                ),
                CustomTextField(
                  hintText: langController.t('enter_location'),
                  prefixIcon: Icons.location_on_outlined,
                  controller: _locationCtl,
                  validator: (v) => _required(v, 'Location'),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    langController.t('required_skills'),
                    style: bodyText1,
                  ),
                ),
                CustomTextField(
                  hintText: langController.t('enter_your_skills'),
                  prefixIcon: Icons.grid_view_rounded,
                  controller: _skillsCtl,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: bottomWidget(
                    text: _submitting
                        ? "Creating..."
                        : langController.t('create_project'),
                    onTap: _submitting ? null : _submit,
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
