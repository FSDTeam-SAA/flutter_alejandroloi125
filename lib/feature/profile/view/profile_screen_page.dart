// // lib/feature/profile/view/profile_screen_page.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../auth/providers/auth_provider.dart';
// import '../providers/profile_provider.dart';
// import 'profile_screen_view.dart';
//
// class ProfileScreenPage extends StatefulWidget {
//   const ProfileScreenPage({super.key});
//
//   @override
//   State<ProfileScreenPage> createState() => _ProfileScreenPageState();
// }
//
// class _ProfileScreenPageState extends State<ProfileScreenPage> {
//   String? _uid;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       // 1) try memory (AuthProvider)
//       final auth = context.read<AuthProvider>();
//       var uid = auth.user?.id;
//
//       // 2) fallback to secure storage (saved at login)
//       uid ??= await auth.repo.tokenStore.readUserId();
//       if (uid == null || uid.isEmpty) return;
//
//       _uid = uid;
//       await context.read<ProfileProvider>().fetch(uid);
//     });
//   }
//
//   Future<void> _refresh() async {
//     if (_uid == null) {
//       final auth = context.read<AuthProvider>();
//       _uid = auth.user?.id ?? await auth.repo.tokenStore.readUserId();
//     }
//     if (_uid != null) {
//       await context.read<ProfileProvider>().fetch(_uid!);
//     }
//   }
//
//   int _count(dynamic v) => (v is List) ? v.length : 0;
//
//   @override
//   Widget build(BuildContext context) {
//     final p  = context.watch<ProfileProvider>();
//     final me = p.me;
//
//     // Prefer normalized URL fields first, then raw string.
//     final String? avatarUrl =
//         me?.imageUrl ?? me?.avatarUrl ?? me?.avatar;
//
//     return ProfileScreenView(
//       name:        me?.name,
//       email:       me?.email,
//       address:     me?.address,
//       avatarUrl:   avatarUrl,
//
//       // counts (safe if lists are null)
//       investCount:  _count(me?.favoriteInvest),
//       projectCount: _count(me?.favoriteProject),
//       auctionCount: _count(me?.favoriteAuction),
//
//       // FIX: use the provider's boolean flag that's commonly named isLoading
//       // (your ProfileProvider exposes `isLoading`; `loading` doesn't exist)
//       loading:      p.isLoading,
//
//       errorMessage: p.error,
//       onRefresh:    _refresh,
//       onLogout: () async {
//         await context.read<AuthProvider>().logout();
//       },
//     );
//   }
// }
//
//
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// //
// // import '../../auth/providers/auth_provider.dart';
// // import '../providers/profile_provider.dart';
// // import 'profile_screen_view.dart';
// //
// // class ProfileScreenPage extends StatefulWidget {
// //   const ProfileScreenPage({super.key});
// //
// //   @override
// //   State<ProfileScreenPage> createState() => _ProfileScreenPageState();
// // }
// //
// // class _ProfileScreenPageState extends State<ProfileScreenPage> {
// //   String? _uid;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addPostFrameCallback((_) async {
// //       // 1) try memory (AuthProvider)
// //       final auth = context.read<AuthProvider>();
// //       var uid = auth.user?.id;
// //
// //       // 2) fallback to secure storage (saved at login)
// //       uid ??= await auth.repo.tokenStore.readUserId();
// //       if (uid == null || uid.isEmpty) return;
// //
// //       _uid = uid;
// //       await context.read<ProfileProvider>().fetch(uid);
// //     });
// //   }
// //
// //   Future<void> _refresh() async {
// //     if (_uid == null) {
// //       final auth = context.read<AuthProvider>();
// //       _uid = auth.user?.id ?? await auth.repo.tokenStore.readUserId();
// //     }
// //     if (_uid != null) {
// //       await context.read<ProfileProvider>().fetch(_uid!);
// //     }
// //   }
// //
// //   int _count(dynamic v) => (v is List) ? v.length : 0;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final p  = context.watch<ProfileProvider>();
// //     final me = p.me;
// //
// //     // avatar can be a string or an object with url
// //     String? avatarUrl;
// //     final a = me?.avatar;
// //     if (a is String) {
// //       avatarUrl = a;
// //     } else if (a is Map) {
// //       avatarUrl = (a?['url'] ?? a?['image'] ?? '').toString();
// //     } else {
// //       avatarUrl = me?.imageUrl;
// //     }
// //
// //     return ProfileScreenView(
// //       name:        me?.name,
// //       email:       me?.email,
// //       address:     me?.address,
// //       avatarUrl:   avatarUrl,
// //
// //       // ✅ Only use camelCase properties that exist on your User model
// //       investCount:  _count(me?.favoriteInvest),
// //       projectCount: _count(me?.favoriteProject),
// //       auctionCount: _count(me?.favoriteAuction),
// //
// //       loading:      p.loading,
// //       errorMessage: p.error,
// //       onRefresh:    _refresh,
// //       onLogout: () async {
// //         await context.read<AuthProvider>().logout();
// //       },
// //     );
// //   }
// // }
// //
// //
// //
// //
