import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../create_service/provider/project_provider.dart';

class ProposalScreen extends StatelessWidget {
  final String projectId;
  const ProposalScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Submit Proposal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F10),
        cardColor: const Color(0xFF1A1B1E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF8C3B),
          secondary: Color(0xFF2A2B30),
        ),
        dividerColor: const Color(0xFF2B2C31),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2B30),
          hintStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2B2C31)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2B2C31)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF8C3B)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
      home: SubmitProposalPage(projectId: projectId),
    );
  }
}

class SubmitProposalPage extends StatefulWidget {
  final String projectId;
  const SubmitProposalPage({super.key, required this.projectId});

  @override
  State<SubmitProposalPage> createState() => _SubmitProposalPageState();
}

class _SubmitProposalPageState extends State<SubmitProposalPage> {
  final _formKey = GlobalKey<FormState>();
  final _budgetCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();
  final _coverCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _budgetCtrl.dispose();
    _daysCtrl.dispose();
    _coverCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final provider = context.read<ProjectProvider>();
    final amount = int.tryParse(_budgetCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final days = int.tryParse(_daysCtrl.text) ?? 0;
    final cover = _coverCtrl.text.trim();

    final ok = await provider.submitProposal(
      projectId: widget.projectId,
      budgetAmount: amount,
      days: days,
      coverLetter: cover,
    );

    setState(() => _submitting = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proposal submitted successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Get.back();
    } else {
      final msg = provider.error?.isNotEmpty == true ? provider.error! : 'Failed to submit proposal';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: const Text('Submit Your Proposal', style: TextStyle(fontWeight: FontWeight.w800)),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.attach_money_rounded),
                  hintText: 'Enter your Price',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter a budget';
                  final value = int.tryParse(v.replaceAll(',', ''));
                  if (value == null || value <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              const _FieldLabel('Delivery Time'),
              TextFormField(
                controller: _daysCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.schedule_rounded),
                  hintText: 'e.g., 10 days',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter delivery time in days';
                  final d = int.tryParse(v);
                  if (d == null || d <= 0) return 'Enter a positive number of days';
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
                decoration: const InputDecoration(
                  hintText: 'Explain why you are the best fit for this project.',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please write a short cover letter';
                  if (v.trim().length < 30) return 'Add a bit more detail (min 30 characters)';
                  return null;
                },
              ),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _submitting
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Submit', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
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
  Widget build(BuildContext context) {
    return Padding(
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
}
