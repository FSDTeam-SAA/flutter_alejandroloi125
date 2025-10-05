// lib/feature/profile/view/profile_screen_view.dart
import 'package:alejandroloi/core/util/images.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/feature/profile/view/about_view.dart';
import 'package:alejandroloi/feature/profile/view/change_password.dart';
import 'package:alejandroloi/feature/profile/view/language_view.dart';
import 'package:alejandroloi/feature/profile/view/privacy_policy.dart';
import 'package:alejandroloi/feature/profile/view/terms_conditon.dart';
import 'package:alejandroloi/feature/profile/view/upload_photos_view.dart';
import 'package:alejandroloi/feature/profile/view/wishlist_view.dart';
import 'package:alejandroloi/feature/profile/widgets/top_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/view/login_screen_view.dart';
import '../../auth/view/personal_info_add_view.dart';

class ProfileScreenView extends StatelessWidget {
  const ProfileScreenView({
    super.key,
    this.name,
    this.email,
    this.address,
    this.avatarUrl,
    this.investCount = 0,
    this.projectCount = 0,
    this.auctionCount = 0,
    this.loading = false,
    this.errorMessage,
    this.onRefresh,
    this.onLogout,
  });

  /// Display fields (optional)
  final String? name;
  final String? email;
  final String? address;
  final String? avatarUrl;

  /// Simple stats
  final int investCount;
  final int projectCount;
  final int auctionCount;

  /// UI state
  final bool loading;
  final String? errorMessage;

  /// Optional hooks you can wire up later
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLogout;

  String get _displayName {
    final n = (name ?? '').trim();
    if (n.isNotEmpty) return n;
    final e = (email ?? '').trim();
    if (e.contains('@')) return e.split('@').first;
    return 'User';
  }

  String get _displayAddress {
    final a = (address ?? '').trim();
    return a.isNotEmpty ? a : 'No address yet';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("My Profile", style: headingText),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: Colors.black,
        onRefresh: () async {
          if (onRefresh != null) {
            await onRefresh!();
          }
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            if ((errorMessage ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(errorMessage!, style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 8),
            ],

            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade700,
                  backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                      ? NetworkImage(avatarUrl!) as ImageProvider
                      : null,
                  child: (avatarUrl == null || avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white70)
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_displayName, style: headingText),
                    Text(_displayAddress, style: bodyText1.copyWith(fontSize: 16)),
                  ],
                ),
                const Spacer(),
                if (loading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
              ],
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  topCard(imagePath: Images.currency, value: "$investCount",  type: "Investments"),
                  topCard(imagePath: Images.layout,   value: "$projectCount", type: "Project"),
                  topCard(imagePath: Images.key,      value: "$auctionCount", type: "Action"),
                ],
              ),
            ),

            // Actions
            profileBottom(
              imagePath: Images.credit,
              name: "Update Personal Information",
              voidCallBack: () {
                Get.to(() => const PersonalInfoAddView(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOut);
              },
            ),
            profileBottom(
              imagePath: Images.terms,
              name: "Upload Photos",
              voidCallBack: () {
                Get.to(() => const UploadProfileView(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOut);
              },
            ),
            profileBottom(
              imagePath: Images.wishlist,
              name: "WishList",
              voidCallBack: () {
                Get.to(() => const WishlistViewScreen(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOut);
              },
            ),
            profileBottom(
              imagePath: Images.lang,
              name: "Language",
              voidCallBack: () {
                Get.to(() => const LanguageViewScreen(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOut);
              },
            ),
            profileBottom(
              imagePath: Images.lock,
              name: "Change Password",
              voidCallBack: () {
                Get.to(() => const ChangePasswordView(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOut);
              },
            ),
            profileBottom(
              imagePath: Images.about,
              name: "About App",
              voidCallBack: () {
                Get.to(() => const AboutView(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOut);
              },
            ),
            profileBottom(
              imagePath: Images.privacy,
              name: "Privacy",
              voidCallBack: () {
                Get.to(() => const PrivacyPolicyScreenView(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOut);
              },
            ),
            profileBottom(
              imagePath: Images.terms,
              name: "Terms & Conditons",
              voidCallBack: () {
                Get.to(() => const TermsConditionScreenView(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOut);
              },
            ),

            // Logout (no provider; optional hook + navigation)
            Container(
              decoration: const BoxDecoration(border: Border.symmetric()),
              child: Column(
                children: [
                  InkWell(
                    onTap: loading
                        ? null
                        : () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Log out?'),
                          content: const Text('You will need to sign in again.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Log out')),
                          ],
                        ),
                      ) ??
                          false;
                      if (!ok) return;

                      if (onLogout != null) {
                        try { await onLogout!(); } catch (_) {}
                      }

                      Get.snackbar('Success', 'Logged Out Successfully',
                          snackPosition: SnackPosition.TOP);

                      Get.offAll(() => LoginScreenView(),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300));
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Log Out',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, color: Colors.red),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(width: double.infinity, color: Colors.white, height: 1.5),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
