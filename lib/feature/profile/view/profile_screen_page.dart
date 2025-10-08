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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = context.read<AuthProvider>().user?.id;
      if (uid != null) {
        await context.read<ProfileProvider>().fetch(uid);
      }
    });
  }

  Future<void> _refresh() async {
    final uid = context.read<AuthProvider>().user?.id;
    if (uid != null) {
      await context.read<ProfileProvider>().fetch(uid);
    }
  }

  // ---- helpers to read fields regardless of how your User model is shaped ----
  String _readAvatar(dynamic me) {
    if (me == null) return '';
    try {
      // 1) typed object with `avatar.url`
      final url = (me.avatar?.url) as String?;
      if (url != null && url.isNotEmpty) return url;
    } catch (_) {}
    try {
      // 2) map-shaped avatar: { url: "..." }
      final url = (me.avatar is Map) ? (me.avatar['url'] as String?) : null;
      if (url != null && url.isNotEmpty) return url;
    } catch (_) {}
    // 3) plain string avatar or other fallbacks your model might expose
    final a = (me.avatar is String) ? me.avatar as String : null;
    if (a != null && a.isNotEmpty) return a;

    final au = (me.avatarUrl is String) ? me.avatarUrl as String : null;
    if (au != null && au.isNotEmpty) return au;

    final img = (me.imageUrl is String) ? me.imageUrl as String : null;
    if (img != null && img.isNotEmpty) return img;

    return '';
  }

  int _len(dynamic v) => v is List ? v.length : 0;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();
    final me = p.me;

    // Basic display fields
    final name    = (me?.name is String)  ? (me!.name as String)   : '';
    final email   = (me?.email is String) ? (me!.email as String)  : '';
    // final address = (me?.address is String) ? (me!.address as String) : '';
    final avatarUrl = _readAvatar(me);

    // Counters: accept both camelCase and snake_case lists
    final dyn = me as dynamic;
    final investCount  = _len(dyn?.favoriteInvest ?? dyn?.favorite_invest);
    final projectCount = _len(dyn?.favoriteProject ?? dyn?.favorite_project);
    final auctionCount = _len(dyn?.favoriteAuction ?? dyn?.favorite_auction);

    return ProfileScreenView(
      name: name,
      email: email,
      // address: address,
      avatarUrl: avatarUrl,
      investCount: investCount,
      projectCount: projectCount,
      auctionCount: auctionCount,
      loading: p.loading,
      errorMessage: p.error,
      onRefresh: _refresh,
      onLogout: () async {
        await context.read<AuthProvider>().logout();
      },
    );
  }
}
