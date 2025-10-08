// lib/feature/profile/view/upload_photos_view.dart
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class UploadProfileView extends StatefulWidget {
  const UploadProfileView({
    super.key,
    this.initialAvatarUrl,
    this.onSubmit, // optional callback if you want to handle the file upstream
  });

  /// Optional avatar URL to show when the screen opens (before user picks).
  final String? initialAvatarUrl;

  /// Optional callback invoked on Update with the selected file.
  /// If provided, it's awaited before closing.
  final Future<void> Function(File file)? onSubmit;

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
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // 1) Prefer explicitly provided URL
    if ((widget.initialAvatarUrl ?? '').isNotEmpty) {
      _avatar = NetworkImage(widget.initialAvatarUrl!);
    } else {
      // 2) Fallback to current user avatar from provider (if loaded)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final me = context.read<ProfileProvider>().me;
        final url = (me?.avatar ?? me?.imageUrl ?? '').toString();
        if (url.isNotEmpty && mounted) {
          setState(() => _avatar = NetworkImage(url));
        }
      });
    }
  }

  // pickers
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

  Future<void> _submit() async {
    if (_selectedFile == null) {
      Get.snackbar('Oops', 'Please select a photo first', snackPosition: SnackPosition.TOP);
      return;
    }

    setState(() => _submitting = true);
    try {
      // If parent wants to handle the file, let it.
      if (widget.onSubmit != null) {
        await widget.onSubmit!(_selectedFile!);
      } else {
        // Otherwise, do API call here via Provider/Repository/Service (Dio)
        final pp = context.read<ProfileProvider>();
        final ok = await pp.update(avatar: _selectedFile);
        if (!ok) throw Exception(pp.error ?? 'Upload failed');

        // Re-fetch user so ProfileProvider.me has the fresh avatar URL
        final auth = context.read<AuthProvider>();
        final uid = auth.user?.id ?? await auth.repo.tokenStore.readUserId();
        if (uid != null) await pp.fetch(uid);
      }

      if (!mounted) return;

      Get.snackbar('Success', 'Profile photo updated', snackPosition: SnackPosition.TOP);

      // Stay on page so buttons remain visible (no Navigator.pop here).
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(.7),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = _submitting;

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
                    onTap: loading ? null : _pickFromCamera,
                  ),
                  const SizedBox(width: 36),
                  _IconAction(
                    icon: CupertinoIcons.photo,
                    label: 'Photos',
                    onTap: loading ? null : _pickFromGallery,
                  ),
                ],
              ),

              const Spacer(),
            ],
          ),
        ),
      ),

      // ✅ Buttons stay visible. They are just disabled while uploading,
      // and the Update button shows a spinner + "Updating..."
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
        child: Row(
          children: [
            // Skip -> back
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: const BorderSide(color: accent, width: 1.6),
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: loading ? null : () => Get.back(),
                child: const Text('Skip',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),

            // Update -> upload via API (provider) or callback
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: loading ? null : _submit,
                child: loading
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Text('Updating...',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                )
                    : const Text('Update',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
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
            const Text('', style: TextStyle(color: Colors.transparent)),
            Text(label,
                style: const TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.w600)),
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
    final inner = size - 10; // outer ring ~5
    final content = size - 24; // inner ring ~7

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
