import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_service/api_client.dart';
import '../../../core/network/api_service/token_store.dart';
import '../../../repository/project_repository.dart';
import '../../../services/project_service.dart';

class ProposalScreen extends StatefulWidget {
  final String projectId;
  const ProposalScreen({super.key, required this.projectId});

  @override
  State<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _budgetCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();
  final _coverCtrl = TextEditingController();

  late final ProjectRepository _repo;
  bool _submitting = false;

  // palette
  static const _bg = Color(0xFF0F0F10);
  static const _field = Color(0xFF2A2B30);
  static const _border = Color(0xFF2B2C31);
  static const _accent = Color(0xFFFF8C3B);

  @override
  void initState() {
    super.initState();
    final tokenStore = TokenStore();
    final apiClient = ApiClient(tokenStore);
    final service = ProjectService(apiClient);
    _repo = ProjectRepository(service);
  }

  @override
  void dispose() {
    _budgetCtrl.dispose();
    _daysCtrl.dispose();
    _coverCtrl.dispose();
    super.dispose();
  }

  int _extractDays(String input) {
    final m = RegExp(r'\d+').firstMatch(input);
    return int.tryParse(m?.group(0) ?? '') ?? 0;
    // allows “10 days” just like the Figma hint
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final amount = int.tryParse(
      _budgetCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
    ) ??
        0;
    final days = _extractDays(_daysCtrl.text);
    final cover = _coverCtrl.text.trim();

    setState(() => _submitting = true);
    try {
      await _repo.submitProposal(
        projectId: widget.projectId,
        coverLetter: cover,
        budget: amount,
        deliveryDays: days,
      );

      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proposal submitted successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Get.back(result: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  InputDecoration _decoration({
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      filled: true,
      fillColor: _field,
      isDense: true,
      hintStyle: const TextStyle(color: Colors.white70),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _accent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,),
          onPressed: () => Get.back(),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        title: const Text(
          'Submit Your Proposal',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              const _FieldLabel('Your Budget'),
              TextFormField(
                controller: _budgetCtrl,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: false),
                decoration: _decoration(
                  hint: 'Enter your Price',
                  icon: Icons.attach_money_rounded,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a budget';
                  }
                  final value = int.tryParse(
                      v.replaceAll(RegExp(r'[^0-9]'), ''));
                  if (value == null || value <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              const _FieldLabel('Delivery Time'),
              TextFormField(
                controller: _daysCtrl,
                keyboardType: TextInputType.text,
                decoration: _decoration(
                  hint: 'e.g., 10 days',
                  icon: Icons.schedule_rounded,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter delivery time';
                  }
                  final d = _extractDays(v);
                  if (d <= 0) return 'Enter a positive number of days';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              const _FieldLabel('Cover Letter'),
              TextFormField(
                controller: _coverCtrl,
                minLines: 5,
                maxLines: 8,
                textInputAction: TextInputAction.newline,
                decoration: _decoration(
                  hint:
                  'Explain why you are the best fit for this project.',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please write a short cover letter';
                  }
                  if (v.trim().length < 30) {
                    return 'Add a bit more detail (min 30 characters)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.black,
                    padding:
                    const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text(
                    'Submit',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13.5,
        color: Colors.white70,
      ),
    ),
  );
}
