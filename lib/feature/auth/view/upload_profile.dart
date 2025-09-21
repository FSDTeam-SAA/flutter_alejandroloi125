import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'login_screen_view.dart';

class UploadProfileView extends StatefulWidget {
  const UploadProfileView({super.key});

  @override
  State<UploadProfileView> createState() => _UploadProfileViewState();
}

class _UploadProfileViewState extends State<UploadProfileView> {
  // Palette
  static const bg       = Color(0xFF0E0E0E);
  static const textMain = Colors.white;
  static const textSub  = Colors.white70;
  static const accent   = Color(0xFFFF7A00);

  ImageProvider? _avatar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: _RoundBack(onTap: () => Navigator.pop(context)),
        title: const Text(
          'Upload Profile',
          style: TextStyle(
            color: textMain,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
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

              // Avatar with double ring (NO grey fill)
              Center(
                child: _DoubleRingAvatar(
                  size: 220,
                  outerColor: accent,
                  innerColor: Colors.white, // clean white inner ring
                  child: CircleAvatar(
                    radius: 95,
                    backgroundColor: Colors.transparent, // ⬅️ no grey
                    backgroundImage: _avatar,
                    child: _avatar == null
                        ? const Icon(
                      CupertinoIcons.person_alt,
                      size: 110,
                      color: Colors.white30, // subtle, not grey block
                    )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Camera / Photos row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _IconAction(
                    icon: CupertinoIcons.camera,
                    label: 'Camera',
                  ),
                  SizedBox(width: 36),
                  _IconAction(
                    icon: CupertinoIcons.photo,
                    label: 'Photos',
                  ),
                ],
              ),


              const Spacer(),

              // Bottom buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accent,
                        side: const BorderSide(color: accent, width: 1.6),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Get.to(() => LoginScreenView(),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      ),



                      child: const Text(
                        'Skip',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Get.to(() => LoginScreenView(),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
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

  // ---- stubbed pickers (hook up image_picker here) ----
  void _pickFromCamera() async {
    // final XFile? file = await ImagePicker().pickImage(source: ImageSource.camera);
    // if (file != null) setState(() => _avatar = FileImage(File(file.path)));
  }

  void _pickFromGallery() async {
    // final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    // if (file != null) setState(() => _avatar = FileImage(File(file.path)));
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;        // 👈 dynamic icon
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
            Icon(icon, color: Colors.white, size: 26),   // 👈 use the dynamic icon
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: accent,                            // orange text
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// Back button with subtle blur and circular tap target
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

// Big circular avatar with two rings (transparent center)
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
    final inner = size - 10;   // outer ring thickness ~5
    final content = size - 24; // inner ring thickness ~7

    return SizedBox(
      width: outer,
      height: outer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring (accent)
          Container(
            width: outer,
            height: outer,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: outerColor, width: 5),
            ),
          ),
          // Inner ring (white)
          Container(
            width: inner,
            height: inner,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: innerColor, width: 7),
            ),
          ),
          // Transparent center with avatar/placeholder
          SizedBox(width: content, height: content, child: child),
        ],
      ),
    );
  }
}


