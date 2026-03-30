import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

final routerProvider = Provider((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final isAuth = token != null && token.isNotEmpty;
      final isOnAuth = state.matchedLocation == '/login' || state.matchedLocation.startsWith('/otp');
      if (!isAuth && !isOnAuth && state.matchedLocation != '/splash') return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/splash',  builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/login',   builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/otp',     builder: (c, s) => OtpScreen(mobile: s.extra as String)),
      GoRoute(path: '/home',    builder: (c, s) => const HomeScreen()),
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
    ],
  );
});
