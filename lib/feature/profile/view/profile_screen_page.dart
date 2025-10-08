import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import 'profile_screen_view.dart';

class ProfileScreenPage extends StatefulWidget {
  const ProfileScreenPage({super.key});

  @override
  State<ProfileScreenPage> createState() => _ProfileScreenPageState();
}

class _ProfileScreenPageState extends State<ProfileScreenPage> {
  @override
  void initState() {
    super.initState();
    // Fetch the profile once the widget is mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      String? uid = auth.user?.id;
      // Fallback to storage if needed
      uid ??= await auth.repo.tokenStore.readUserId();
      if (uid != null) {
        await context.read<ProfileProvider>().fetch(uid);
      }
    });
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthProvider>();
    String? uid = auth.user?.id ?? await auth.repo.tokenStore.readUserId();
    if (uid != null) {
      await context.read<ProfileProvider>().fetch(uid);
    }
  }

  /// Safely pull an avatar URL regardless of how your `User` model stores it.
  String? _avatarUrl(dynamic user) {
    try {
      // Supports: user.avatarUrl, user.avatar.url, user.avatar['url']
      final dyn = user as dynamic;
      final a = dyn.avatarUrl ??
          (dyn.avatar != null && dyn.avatar is Map
              ? (dyn.avatar['url'] ?? dyn.avatar['image_url'])
              : (dyn.avatar != null && dyn.avatar.url != null ? dyn.avatar.url : null));
      if (a == null) return null;
      final s = a.toString();
      return s.isEmpty ? null : s;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();
    final me = p.me;

    final name = me?.name ?? '';
    final email = me?.email ?? '';
    final address = me?.address ?? '';
    final avatarUrl = _avatarUrl(me);

    // Optional counters (defaults to 0 if your model doesn't have these)
    final investCount = (me?.favoriteInvest?.length ?? 0);
    final projectCount = (me?.favoriteProject?.length ?? 0);
    final auctionCount = (me?.favoriteAuction?.length ?? 0);

    return ProfileScreenView(
      name: name,
      email: email,
      address: address,
      avatarUrl: avatarUrl,
      investCount: investCount,
      projectCount: projectCount,
      auctionCount: auctionCount,
      loading: p.loading,
      errorMessage: p.error,
      onRefresh: _refresh,
      onLogout: () async {
        await context.read<AuthProvider>().logout();
        Get.back(); // or navigate to login if you don't already elsewhere
      },
    );
  }
}
