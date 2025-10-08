import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import '../../../../providers/project_provider.dart';
import '../../../models/project.dart';

// ---- palette to match the rest of your app ----
const _bg = Color(0xFF000000);
const _accent = Color(0xFFFF7A00);
const _textDim = Colors.white70;
const _chipBg = Color(0xFF2C2C30);

class MyEventProjectDetail extends StatefulWidget {
  final String projectId;
  const MyEventProjectDetail({super.key, required this.projectId});

  @override
  State<MyEventProjectDetail> createState() => _MyEventProjectDetailState();
}

class _MyEventProjectDetailState extends State<MyEventProjectDetail> {
  Project? _p;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _load();
    });
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final p = await context.read<ProjectProvider>().getById(widget.projectId);
      if (!mounted) return;
      setState(() { _p = p; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _markCompleted() async {
    if (_p == null) return;
    setState(() => _loading = true);

    // backend expects "complete"
    final ok = await context.read<ProjectProvider>()
        .update(_p!.id, status: 'complete');

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      // pop with a signal so list can refresh instantly
      Get.back(result: true);
      Get.snackbar('Updated', 'Project marked as Completed',
          snackPosition: SnackPosition.TOP);
    } else {
      final err = context.read<ProjectProvider>().error ?? 'Update failed';
      Get.snackbar('Error', err, snackPosition: SnackPosition.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(_error!, style: const TextStyle(color: Colors.white70)),
            ),
          ),
        ),
      );
    }
    if (_p == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: Text('Project not found', style: TextStyle(color: Colors.white70))),
      );
    }

    final p = _p!;
    final budget = _budgetRange(p.minBudget, p.maxBudget);
    final duration = p.deadlineDays > 0 ? '${p.deadlineDays} Days' : '-';
    final skills = p.skills;
    final isDone = _isCompleted(p.status);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _roundIcon(Icons.arrow_back, () => Navigator.maybePop(context)),
                  const Spacer(),
                  _roundIcon(Icons.favorite_border, () {}),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                (p.category.isEmpty ? '—' : p.category),
                style: const TextStyle(color: _accent, fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),

              Text(
                p.title,
                style: const TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.15,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                p.description.isEmpty ? 'No description' : p.description,
                style: const TextStyle(color: _textDim, fontSize: 13.5, height: 1.35),
              ),
              const SizedBox(height: 16),

              _twoCols(
                leftIcon: Icons.attach_money, leftText: budget,
                rightIcon: Icons.schedule, rightText: duration,
              ),
              const SizedBox(height: 8),
              _twoCols(
                leftIcon: Icons.location_on_outlined,
                leftText: (p.location.isEmpty ? '—' : p.location),
                rightIcon: Icons.info_outline,
                rightText: 'Status: ${_statusLabel(p.status)}',
              ),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isDone ? null : _markCompleted,
                  child: Text(isDone ? 'Completed' : 'Complete',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 18),

              const Text('Project Description',
                  style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(p.description.isEmpty ? '—' : p.description,
                  style: const TextStyle(color: _textDim, fontSize: 13.5, height: 1.45)),
              const SizedBox(height: 18),

              const Text('Skills Required',
                  style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              skills.isEmpty
                  ? const Text('No skills listed', style: TextStyle(color: _textDim))
                  : Wrap(
                spacing: 8, runSpacing: 8,
                children: skills.map((s) => _SkillChip(s)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static bool _isCompleted(String? s) {
    final v = (s ?? '').toLowerCase().trim();
    return v == 'complete' || v == 'completed';
  }

  static String _statusLabel(String? s) {
    final v = (s ?? '').toLowerCase().trim();
    if (v == 'complete' || v == 'completed') return 'Completed';
    if (v.isEmpty) return '—';
    return '${v[0].toUpperCase()}${v.substring(1)}';
  }

  // round icon button
  static Widget _roundIcon(IconData icon, VoidCallback onTap) {
    return InkResponse(
      onTap: onTap, radius: 28,
      child: Container(
        height: 36, width: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}

// --- helpers ---
class _twoCols extends StatelessWidget {
  final IconData leftIcon;
  final String leftText;
  final IconData rightIcon;
  final String rightText;

  const _twoCols({
    required this.leftIcon, required this.leftText,
    required this.rightIcon, required this.rightText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _iconText(leftIcon, leftText)),
        const SizedBox(width: 10),
        Expanded(child: _iconText(rightIcon, rightText, alignEnd: true)),
      ],
    );
  }

  static Widget _iconText(IconData icon, String text, {bool alignEnd = false}) {
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Flexible(
          child: Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
    return alignEnd ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [row]) : row;
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: _chipBg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12.5)),
    );
  }
}

// ---------- local formatters ----------
String _budgetRange(int min, int max) {
  if (min == 0 && max == 0) return '-';
  if (min > 0 && max > 0) return '${_comma(min)} - ${_comma(max)}';
  if (min > 0) return 'From ${_comma(min)}';
  return 'Up to ${_comma(max)}';
}

String _comma(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    b.write(s[i]);
    final left = s.length - i - 1;
    if (left % 3 == 0 && left != 0) b.write(',');
  }
  return b.toString();
}
