// lib/feature/profile/view/profile_screen_view.dart
import 'dart:async';
import 'dart:convert';

import 'package:alejandroloi/core/util/images.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/feature/profile/view/about_view.dart';
import 'package:alejandroloi/feature/profile/view/change_password.dart';
import 'package:alejandroloi/feature/profile/view/language_view.dart';
import 'package:alejandroloi/feature/profile/view/privacy_policy.dart';
import 'package:alejandroloi/feature/profile/view/terms_conditon.dart';
import 'package:alejandroloi/feature/profile/view/wishlist_view.dart';
import 'package:alejandroloi/feature/profile/widgets/top_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../constants/api_constants.dart';
import '../../auth/controllers/auth_provider.dart';
import '../../auth/models/user_model.dart';
import '../../auth/view/login_screen_view.dart';
import '../../auth/view/personal_info_add_view.dart';
import '../../auth/view/upload_profile.dart';

class ProfileScreenView extends StatefulWidget {
  const ProfileScreenView({super.key});

  @override
  State<ProfileScreenView> createState() => _ProfileScreenViewState();
}

class _ProfileScreenViewState extends State<ProfileScreenView> {
  bool _loading = false; // kept for logic, no longer shown as a bar
  String? _error;

  User? _user;
  int _investCount = 0;
  int _projectCount = 0;
  int _actionCount = 0;

  // --- Warm-up ping to wake sleeping servers (optional but helps) ---
  Future<void> _warmUp() async {
    try {
      final uri = ApiConstants.endpoint(['health']);
      await http.get(uri, headers: ApiConstants.headers())
          .timeout(const Duration(seconds: 7));
    } catch (_) {
      // ignore – warm-up is best-effort
    }
  }

  // --- GET with one retry on timeout (25s -> 45s) ---
  Future<http.Response> _getWithRetry(Uri uri, {String? bearer}) async {
    try {
      return await http
          .get(uri, headers: ApiConstants.headers(bearer: bearer))
          .timeout(const Duration(seconds: 25));
    } on TimeoutException {
      await Future.delayed(const Duration(milliseconds: 500));
      return await http
          .get(uri, headers: ApiConstants.headers(bearer: bearer))
          .timeout(const Duration(seconds: 45));
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final id = auth.user?.id;
      if (id == null || id.isEmpty) {
        setState(() => _error = 'Missing user id.');
        return;
      }

      await _warmUp();

      final uri = ApiConstants.endpoint(['user', 'single-user', id]);
      final res = await _getWithRetry(uri, bearer: auth.token);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        final data = (decoded is Map && decoded['data'] is Map)
            ? (decoded['data'] as Map).cast<String, dynamic>()
            : <String, dynamic>{};

        // Normalize for your existing User.fromJson
        final flat = Map<String, dynamic>.from(data);

        if (data['avatar'] is Map) {
          flat['avatar'] =
              (data['avatar']['url'] as String?) ?? (data['avatarUrl'] as String?);
        }

        String? _formatAddress(dynamic a) {
          if (a == null) return null;
          if (a is String) return a.trim().isEmpty ? null : a.trim();
          if (a is Map) {
            final parts = [a['street'], a['city'], a['state'], a['zipCode']]
                .whereType<String>()
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            return parts.isEmpty ? null : parts.join(', ');
          }
          return null;
        }
        flat['address'] = _formatAddress(data['address']);

        String _fallbackName() {
          final n = (data['name'] as String?)?.trim() ?? '';
          if (n.isNotEmpty) return n;
          final u = (data['username'] as String?)?.trim();
          if (u != null && u.isNotEmpty) return u;
          final email = (data['email'] as String?) ?? '';
          return email.contains('@') ? email.split('@').first : 'User';
        }
        flat['name'] = _fallbackName();

        _user = User.fromJson(flat);
        _investCount  = (data['favorite_invest']  as List?)?.length ?? 0;
        _projectCount = (data['favorite_project'] as List?)?.length ?? 0;
        _actionCount  = (data['favorite_auction'] as List?)?.length ?? 0;
      } else {
        try {
          final m = jsonDecode(res.body);
          _error = (m is Map && m['message'] != null)
              ? m['message'].toString()
              : 'Failed [${res.statusCode}]';
        } catch (_) {
          _error = 'Failed [${res.statusCode}]';
        }
      }
    } on TimeoutException {
      _error = 'Request timed out.';
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final displayName = (() {
      final n = _user?.name.trim() ?? '';
      if (n.isNotEmpty) return n;
      final email = _user?.email ?? '';
      return email.contains('@') ? email.split('@').first : 'User';
    })();

    final displayAddress =
    (_user?.address?.trim().isNotEmpty == true) ? _user!.address! : 'No address yet';

    final avatarUrl = _user?.avatarUrl;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              // removed the LinearProgressIndicator block

              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                const SizedBox(height: 12),
              ],

              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade700,
                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? NetworkImage(avatarUrl) as ImageProvider
                        : null,
                    child: (avatarUrl == null || avatarUrl.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white70)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: headingText),
                      Text(displayAddress, style: bodyText1.copyWith(fontSize: 16)),
                    ],
                  ),
                ],
              ),

              // Stats
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    topCard(imagePath: Images.currency, value: "$_investCount", type: "Investments"),
                    topCard(imagePath: Images.layout, value: "$_projectCount", type: "Project"),
                    topCard(imagePath: Images.key, value: "$_actionCount", type: "Action"),
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

              // Logout
              Container(
                decoration: const BoxDecoration(border: Border.symmetric()),
                child: Column(
                  children: [
                    InkWell(
                      onTap: auth.loading
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

                        await context.read<AuthProvider>().logout();
                        if (!mounted) return;

                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Logged out')));

                        Get.offAll(() =>  LoginScreenView(),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 300));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: const [
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
      ),
    );
  }
}
