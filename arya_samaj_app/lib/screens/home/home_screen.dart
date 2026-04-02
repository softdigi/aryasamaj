import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../models/feature_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);
    final isOffline = ref.watch(homeOfflineProvider);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      drawer: _AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text('आर्य समाज'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => context.push('/search')),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: Column(children: [
        if (isOffline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            color: AppColors.warning,
            child: const Row(children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('ऑफलाइन मोड — कैश डेटा दिखाया जा रहा है',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
        Expanded(child: homeAsync.when(
        loading: () => const _HomeShimmer(),
        error: (e, _) => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.wifi_off, size: 60, color: AppColors.saffron),
            const SizedBox(height: 12),
            const Text('इंटरनेट कनेक्शन नहीं है', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(homeProvider),
              child: const Text('पुनः प्रयास करें'),
            ),
          ]),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(homeProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _SectionHeader(title: 'संगठन'),
              _FeatureGrid(features: data.sangathan),
              _SectionHeader(title: 'सुविधा'),
              _FeatureGrid(features: data.suvidha),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      )),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.saffron,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  final List<FeatureModel> features;
  const _FeatureGrid({required this.features});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: features.length,
        itemBuilder: (ctx, i) {
          final f = features[i];
          return GestureDetector(
            onTap: () => context.push(f.route),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                f.icon != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        f.icon!,
                        width: 52, height: 52, fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.grid_view, size: 40, color: AppColors.saffron),
                      ),
                    )
                  : const Icon(Icons.grid_view, size: 40, color: AppColors.saffron),
                const SizedBox(height: 6),
                Text(
                  f.nameHindi ?? f.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(height: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30))),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: 9,
            itemBuilder: (c, i) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
          ),
        ]),
      ),
    );
  }
}


// ── App Drawer ────────────────────────────────────────────────────────────────

class _AppDrawer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.saffron),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.account_circle, color: Colors.white, size: 52),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.appName,
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text(AppStrings.tagline,
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerTile(icon: Icons.home_outlined,        label: AppStrings.home,      route: '/home'),
                _DrawerTile(icon: Icons.library_books_outlined, label: AppStrings.library, route: '/library'),
                _DrawerTile(icon: Icons.event_outlined,       label: AppStrings.events,    route: '/events'),
                _DrawerTile(icon: Icons.people_outline,       label: AppStrings.members,   route: '/members'),
                _DrawerTile(icon: Icons.volunteer_activism_outlined, label: AppStrings.donation, route: '/donation'),
                _DrawerTile(icon: Icons.person_outline,       label: AppStrings.profile,   route: '/profile'),
                _DrawerTile(icon: Icons.feedback_outlined,    label: AppStrings.feedback,  route: '/feedback'),
                const Divider(),
                _DrawerTile(icon: Icons.search,               label: AppStrings.search,    route: '/search'),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(AppStrings.logout,
                  style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.of(context).pop();
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  const _DrawerTile({required this.icon, required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.saffron),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }
}
