import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
      GoRoute(path: '/home',    builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/profile-setup', builder: (c, s) => const ProfileSetupScreen()),
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
      GoRoute(path: '/library',  builder: (c, s) => const LibraryScreen()),
      GoRoute(path: '/events',   builder: (c, s) => const EventsScreen()),
      GoRoute(path: '/donation', builder: (c, s) => const DonationScreen()),
      GoRoute(path: '/feedback', builder: (c, s) => const FeedbackScreen()),
      GoRoute(path: '/profile',  builder: (c, s) => const ProfileScreen()),
      GoRoute(path: '/search',   builder: (c, s) => const SearchScreen()),
      GoRoute(path: '/members',  builder: (c, s) => const MembersScreen()),
      GoRoute(path: '/members/:id', builder: (c, s) => MemberDetailScreen(memberId: int.parse(s.pathParameters['id']!))),
    ],
  );
});
