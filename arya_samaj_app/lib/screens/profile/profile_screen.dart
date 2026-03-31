import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('प्रोफाइल')),
      body: FutureBuilder<Map<String, String?>>(
        future: Future.wait([
          _storage.read(key: 'user_mobile'),
          _storage.read(key: 'profile_complete'),
        ]).then((vals) => {'user_mobile': vals[0], 'profile_complete': vals[1]}),
        builder: (ctx, snap) {
          final mobile = snap.data?['user_mobile'] ?? '';
          final profileComplete = snap.data?['profile_complete'] == 'true';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.saffron.withOpacity(.1),
                  border: Border.all(color: AppColors.saffron, width: 2),
                ),
                child: const Icon(Icons.person, size: 56, color: AppColors.saffron),
              ),
              const SizedBox(height: 12),
              Text(mobile.isNotEmpty ? '+91 $mobile' : 'उपयोगकर्ता',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              if (!profileComplete) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.saffronLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.saffron),
                  ),
                  child: const Text('प्रोफाइल अधूरी है', style: TextStyle(color: AppColors.saffron, fontSize: 12)),
                ),
              ],
              const SizedBox(height: 24),
              _tile(Icons.edit, profileComplete ? 'प्रोफाइल संपादित करें' : 'प्रोफाइल सेटअप करें',
                  () => context.go('/profile-setup')),
              _tile(Icons.people_outline, 'सदस्य निर्देशिका', () => context.go('/members')),
              _tile(Icons.notifications_outlined, 'अधिसूचनाएं', () {}),
              _tile(Icons.share, 'ऐप शेयर करें', () {}),
              _tile(Icons.star_outline, 'ऐप रेट करें', () {}),
              _tile(Icons.info_outline, 'आर्य समाज के बारे में', () {}),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.error),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton.icon(
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text('लॉगआउट', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 16)),
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _tile(IconData icon, String label, VoidCallback onTap) => ListTile(
    leading: Icon(icon, color: AppColors.saffron),
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
    onTap: onTap,
    shape: Border(bottom: BorderSide(color: Colors.grey.shade100)),
  );
}

