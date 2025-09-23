// lib/feature/auth/view/upload_profile_view.dart
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../app_ground.dart';
import '../controllers/onboarding_provider.dart';
import 'login_screen_view.dart';

class UploadProfileView extends StatefulWidget {
  const UploadProfileView({super.key});

  @override
  State<UploadProfileView> createState() => _UploadProfileViewState();
}

class _UploadProfileViewState extends State<UploadProfileView> {
  // Palette
  static const bg = Color(0xFF0E0E0E);
  static const textMain = Colors.white;
  static const textSub = Colors.white70;
  static const accent = Color(0xFFFF7A00);

  final _picker = ImagePicker();
  File? _selectedFile;
  ImageProvider? _avatar;

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<OnboardingProvider>();
    final isLoading = flow.loading;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: _RoundBack(onTap: () => Navigator.pop(context)),
        title: const Text(
          'Upload Profile',
          style: TextStyle(color: textMain, fontSize: 22, fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'To create your new account, provide one of your photos.',
                style: TextStyle(color: textSub, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Avatar with double ring (transparent center)
              Center(
                child: _DoubleRingAvatar(
                  size: 220,
                  outerColor: accent,
                  innerColor: Colors.white,
                  child: CircleAvatar(
                    radius: 95,
                    backgroundColor: Colors.transparent,
                    backgroundImage: _avatar,
                    child: _avatar == null
                        ? const Icon(CupertinoIcons.person_alt, size: 110, color: Colors.white30)
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Camera / Photos row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _IconAction(
                    icon: CupertinoIcons.camera,
                    label: 'Camera',
                    onTap: _pickFromCamera,
                  ),
                  const SizedBox(width: 36),
                  _IconAction(
                    icon: CupertinoIcons.photo,
                    label: 'Photos',
                    onTap: _pickFromGallery,
                  ),
                ],
              ),

              const Spacer(),

              // Bottom buttons
              Row(
                children: [
                  // Skip -> go to app (no upload)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accent,
                        side: const BorderSide(color: accent, width: 1.6),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                        Get.offAll(() => const AppGround(),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 300));
                      },
                      child: const Text('Skip',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Continue -> upload if chosen, else warn
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                        if (_selectedFile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a photo first')),
                          );
                          return;
                        }
                        final ok = await context
                            .read<OnboardingProvider>()
                            .uploadProfileImage(_selectedFile!);
                        if (!mounted) return;
                        if (ok) {
                          Get.offAll(() => const AppGround(),
                              transition: Transition.rightToLeft,
                              duration: const Duration(milliseconds: 300));
                        } else {
                          final err = context.read<OnboardingProvider>().error ??
                              'Upload failed';
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(err)));
                        }
                      },
                      child: Text(isLoading ? 'Uploading...' : 'Continue',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- pickers ----
  Future<void> _pickFromCamera() async {
    final x = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (x != null) {
      setState(() {
        _selectedFile = File(x.path);
        _avatar = FileImage(_selectedFile!);
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) {
      setState(() {
        _selectedFile = File(x.path);
        _avatar = FileImage(_selectedFile!);
      });
    }
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const accent = _UploadProfileViewState.accent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 6),
            const Text('',
              style: TextStyle(color: Colors.transparent), // spacer line fix
            ),
            Text(
              label,
              style: const TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundBack extends StatelessWidget {
  const _RoundBack({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: Colors.white.withOpacity(0.10),
            child: InkWell(
              onTap: onTap,
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(CupertinoIcons.back, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DoubleRingAvatar extends StatelessWidget {
  const _DoubleRingAvatar({
    required this.size,
    required this.outerColor,
    required this.innerColor,
    required this.child,
  });

  final double size;
  final Color outerColor;
  final Color innerColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final outer = size;
    final inner = size - 10; // outer ring thickness ~5
    final content = size - 24; // inner ring thickness ~7

    return SizedBox(
      width: outer,
      height: outer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: outer,
            height: outer,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: outerColor, width: 5),
            ),
          ),
          Container(
            width: inner,
            height: inner,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: innerColor, width: 7),
            ),
          ),
          SizedBox(width: content, height: content, child: child),
        ],
      ),
    );
  }
}
