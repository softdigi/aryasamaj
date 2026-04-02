import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'navigator_key.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/widgets/main_scaffold.dart';
import '../../models/content_model.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/otp_screen.dart';
import '../../screens/home/splash_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/categories/category_screen.dart';
import '../../screens/contents/content_list_screen.dart';
import '../../screens/contents/pdf_viewer_screen.dart';
import '../../screens/contents/audio_player_screen.dart';
import '../../screens/contents/video_player_screen.dart';
import '../../screens/library/library_screen.dart';
import '../../screens/events/events_screen.dart';
import '../../screens/donation/donation_screen.dart';
import '../../screens/feedback/feedback_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/profile_setup/profile_setup_screen.dart';
import '../../screens/members/members_screen.dart';
import '../../screens/members/member_detail_screen.dart';

final routerProvider = Provider((ref) {
  const storage = FlutterSecureStorage();
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) async {
      final token = await storage.read(key: 'auth_token');
      final isAuth = token != null && token.isNotEmpty;
      final loc = state.matchedLocation;
      final isOnAuth = loc == '/login' || loc.startsWith('/otp');
      final isSetup  = loc == '/profile-setup';

      if (!isAuth && !isOnAuth && loc != '/splash') return '/login';

      if (isAuth && !isOnAuth && loc != '/splash' && !isSetup) {
        final profileComplete = (await storage.read(key: 'profile_complete')) == 'true';
        if (!profileComplete) return '/profile-setup';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash',  builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/login',   builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/otp',     builder: (c, s) => OtpScreen(mobile: s.extra as String)),
      GoRoute(path: '/profile-setup', builder: (c, s) => const ProfileSetupScreen()),
      GoRoute(path: '/search',   builder: (c, s) => const SearchScreen()),
      GoRoute(path: '/feedback', builder: (c, s) => const FeedbackScreen()),
      GoRoute(path: '/categories', builder: (c, s) {
        final extra = s.extra as Map?;
        return CategoryScreen(parentId: extra?['parent_id'], title: extra?['title'] ?? 'श्रेणियां');
      }),
      GoRoute(path: '/contents', builder: (c, s) {
        final extra = s.extra as Map;
        return ContentListScreen(categoryId: extra['category_id'], title: extra['title'] ?? 'सामग्री');
      }),
      GoRoute(path: '/pdf',    builder: (c, s) => PdfViewerScreen(url: s.extra as String)),
      GoRoute(path: '/audio',  builder: (c, s) => AudioPlayerScreen(categoryId: s.extra as int)),
      GoRoute(path: '/video',  builder: (c, s) => VideoPlayerScreen(url: s.extra as String)),
      // Deep-link route for notification: /contents/:id
      GoRoute(path: '/contents/:id', builder: (c, s) {
        final id = int.parse(s.pathParameters['id']!);
        return _ContentDeepLinkScreen(contentId: id);
      }),
      GoRoute(path: '/members/:id', builder: (c, s) =>
          MemberDetailScreen(memberId: int.parse(s.pathParameters['id']!))),
      GoRoute(path: '/events', builder: (c, s) => const EventsScreen()),

      // ── Main shell with BottomNavigationBar ─────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home',     builder: (c, s) => const HomeScreen()),
          GoRoute(path: '/library',  builder: (c, s) => const LibraryScreen()),
          GoRoute(path: '/members',  builder: (c, s) => const MembersScreen()),
          GoRoute(path: '/donation', builder: (c, s) => const DonationScreen()),
          GoRoute(path: '/profile',  builder: (c, s) => const ProfileScreen()),
        ],
      ),
    ],
  );
});

/// Fetches content by ID and redirects to the appropriate viewer.
class _ContentDeepLinkScreen extends ConsumerWidget {
  final int contentId;
  const _ContentDeepLinkScreen({required this.contentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.read(apiClientProvider);
    return FutureBuilder(
      future: api.get('${ApiEndpoints.contents}/$contentId'),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError || snap.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('सामग्री')),
            body: const Center(child: Text('लोड नहीं हो सका')),
          );
        }
        final content = ContentModel.fromJson(snap.data!.data['data'] as Map);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          switch (content.type) {
            case 'pdf':
              if (content.fileUrl != null) {
                context.push('/pdf', extra: content.fileUrl);
              }
              break;
            case 'audio':
              context.push('/audio', extra: content.id);
              break;
            case 'video':
              if (content.fileUrl != null) {
                context.push('/video', extra: content.fileUrl);
              }
              break;
          }
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}