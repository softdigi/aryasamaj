import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/members_provider.dart';

class MemberDetailScreen extends ConsumerWidget {
  final int memberId;
  const MemberDetailScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(memberDetailProvider(memberId));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
        error: (e, _) => Center(child: Text('लोड नहीं हुआ: $e', style: const TextStyle(color: AppColors.error))),
        data: (member) {
          final imgs = member.images;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppColors.saffron,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: imgs.isNotEmpty
                      ? CachedNetworkImage(imageUrl: imgs.first.url, fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _profileFallback(member.profileImage))
                      : _profileFallback(member.profileImage),
                ),
                title: Text(member.name, style: const TextStyle(fontSize: 16)),
                actions: [
                  if (member.isVerified)
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.verified, color: Colors.white),
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + location
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(member.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                                if (member.username != null)
                                  Text('@${member.username}', style: const TextStyle(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          if (member.profileViews != null)
                            Row(children: [
                              const Icon(Icons.visibility_outlined, size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text('${member.profileViews}', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                            ]),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (member.state != null || member.district != null)
                        _infoRow(Icons.location_on_outlined, [member.district, member.state, member.country]
                            .whereType<String>().join(', ')),
                      if (member.mobile != null)
                        _infoRow(Icons.phone_outlined, member.mobile!),
                      if (member.dob != null)
                        _infoRow(Icons.cake_outlined, member.dob!),

                      // Categories
                      if (member.categories.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text('श्रेणियां', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: member.categories.map((c) => Chip(
                            label: Text(c.name, style: const TextStyle(fontSize: 12)),
                            backgroundColor: c.group == 'role' ? AppColors.saffronLight : AppColors.forestLight,
                            side: BorderSide(color: c.group == 'role' ? AppColors.saffron : AppColors.forest),
                          )).toList(),
                        ),
                      ],

                      // Org
                      if (member.orgType != null || member.orgName != null) ...[
                        const SizedBox(height: 16),
                        const Text('संस्था', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 6),
                        if (member.orgType != null) _infoRow(Icons.business_outlined, member.orgType!),
                        if (member.orgName != null) _infoRow(Icons.apartment, member.orgName!),
                      ],

                      // About
                      if (member.about != null && member.about!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text('परिचय', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 8),
                        Text(member.about!, style: const TextStyle(height: 1.6, color: AppColors.textPrimary)),
                      ],

                      // Image gallery
                      if (imgs.length > 1) ...[
                        const SizedBox(height: 20),
                        const Text('फोटो गैलरी', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: imgs.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (ctx, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: imgs[i].url, width: 120, height: 120, fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(width: 120, height: 120, color: AppColors.border),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _profileFallback(String? url) => url != null
      ? CachedNetworkImage(imageUrl: url, fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _iconFallback())
      : _iconFallback();

  Widget _iconFallback() => Container(
    color: AppColors.saffronLight,
    child: const Center(child: Icon(Icons.person, size: 80, color: AppColors.saffron)),
  );

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppColors.saffron),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary))),
      ],
    ),
  );
}
