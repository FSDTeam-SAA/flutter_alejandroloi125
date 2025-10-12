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
import 'package:alejandroloi/constants/api_paths.dart';
import 'package:alejandroloi/core/network/api_service/api_client.dart';
import 'package:alejandroloi/feature/auth/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../auth/view/login_screen_view.dart';
import '../../auth/view/personal_info_add_view.dart';

/// Pulls the latest name, address and avatar from server and updates UI.
class ProfileScreenView extends StatefulWidget {
  const ProfileScreenView({super.key});

  @override
  State<ProfileScreenView> createState() => _ProfileScreenViewState();
}

class _ProfileScreenViewState extends State<ProfileScreenView> {
  late final Dio _dio;

  bool _loading = true;
  String? _error;

  // Displayed fields
  String? _name;
  String? _email;
  String? _address;
  String? _avatarUrl;

  // Simple stats (you can update from API later if needed)
  int _investCount = 0;
  int _projectCount = 0;
  int _auctionCount = 0;

  @override
  void initState() {
    super.initState();
    _dio = context.read<ApiClient>().dio;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1) Start with whatever we already have in AuthProvider
      final me = context.read<AuthProvider>().user;
      if (me != null) {
        _name = (me.name ?? '').trim().isNotEmpty ? me.name : _name;
        _email = me.email;
        _address = (me.address ?? '').trim().isNotEmpty ? me.address : _address;

        // Try multiple avatar fields
        _avatarUrl = me.imageUrl ?? me.avatarUrl ?? me.avatar ?? _avatarUrl;
      }

      // 2) Fetch fresh user from backend (if id exists)
      final userId = me?.id ?? context.read<AuthProvider>().user?.id;
      if (userId != null && userId.isNotEmpty) {
        final r = await _dio.get(ApiPaths.userGetOne(userId));
        final map = (r.data is Map) ? r.data as Map : {};
        final data = map['data'];

        if (data is Map) {
          final name = _text(data['name']);
          if (name.isNotEmpty) _name = name;

          final addr = _text(data['address'] ?? data['location'] ?? data['nationality']);
          if (addr.isNotEmpty) _address = addr;

          // avatar may be string or { url: ... }
          final a = data['avatar'];
          String? url;
          if (a is String && a.trim().isNotEmpty) {
            url = a.trim();
          } else if (a is Map && a['url'] != null) {
            url = a['url'].toString();
          }
          if (url != null && url.isNotEmpty) _avatarUrl = url;

          // Optional counters if backend provides them
          _investCount = _asInt(data['investCount'] ?? _investCount);
          _projectCount = _asInt(data['projectCount'] ?? _projectCount);
          _auctionCount = _asInt(data['auctionCount'] ?? _auctionCount);
        }
      }

      setState(() => _loading = false);
    } on DioException catch (e) {
      final d = e.response?.data;
      final msg = (d is Map && d['message'] is String)
          ? d['message'] as String
          : (e.message ?? 'Request failed');
      setState(() {
        _error = msg;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  static String _text(dynamic v) => v == null ? '' : v.toString().trim();
  static int _asInt(dynamic v) =>
      (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;

  String get _displayName {
    final n = (_name ?? '').trim();
    if (n.isNotEmpty) return n;
    final e = (_email ?? '').trim();
    if (e.contains('@')) return e.split('@').first;
    return 'User';
  }

  String get _displayAddress {
    final a = (_address ?? '').trim();
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
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            if ((_error ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 8),
            ],

            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade700,
                  backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                      ? NetworkImage(_avatarUrl!) as ImageProvider
                      : null,
                  child: (_avatarUrl == null || _avatarUrl!.isEmpty)
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
                if (_loading)
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
                  topCard(imagePath: Images.currency, value: "$_investCount",  type: "Investments"),
                  topCard(imagePath: Images.layout,   value: "$_projectCount", type: "Project"),
                  topCard(imagePath: Images.key,      value: "$_auctionCount", type: "Auctions"),
                ],
              ),
            ),

            // Actions
            profileBottom(
              imagePath: Images.credit,
              name: "Personal Information",
              voidCallBack: () async {
                final changed = await Get.to<bool>(
                      () => const PersonalInfoAddView(),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOut,
                );
                // if user saved changes → reload profile
                if (changed == true) {
                  await _load();
                }
              },
            ),
            profileBottom(
              imagePath: Images.terms,
              name: "Update Photos",
              voidCallBack: () async {
                await Get.to(() => const UploadProfileView(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOut);
                // after photo update, refresh to get new avatar
                await _load();
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
              name: "Terms & Conditions",
              voidCallBack: () {
                Get.to(() => const TermsConditionScreenView(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOut);
              },
            ),

            // Logout
            Container(
              decoration: const BoxDecoration(border: Border.symmetric()),
              child: Column(
                children: [
                  InkWell(
                    onTap: _loading
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
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Log out'),
                            ),
                          ],
                        ),
                      ) ??
                          false;
                      if (!ok) return;

                      try {
                        await context.read<AuthProvider>().logout();
                      } catch (_) {}

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
