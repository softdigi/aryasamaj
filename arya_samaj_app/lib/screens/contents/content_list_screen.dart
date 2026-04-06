import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/services/cache_service.dart';
import '../../models/content_model.dart';

final contentListProvider =
    FutureProvider.family<List<ContentModel>, int>((ref, categoryId) async {
  final cacheKey = 'contents_$categoryId';
  final api = ref.read(apiClientProvider);

  try {
    final res = await api.get(ApiEndpoints.contents, params: {'category_id': categoryId});
    final list = res.data['data'] as List;
    await CacheService.set(cacheKey, list);
    return list.map((e) => ContentModel.fromJson(e)).toList();
  } catch (_) {
    final cached = CacheService.get(cacheKey) as List?;
    if (cached != null) {
      return cached.map((e) => ContentModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    rethrow;
  }
});

class ContentListScreen extends ConsumerWidget {
  final int categoryId;
  final String title;
  const ContentListScreen({super.key, required this.categoryId, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentsAsync = ref.watch(contentListProvider(categoryId));
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(title: Text(title)),
      body: contentsAsync.when(
        loading: () => _buildShimmer(),
        error: (e, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off, size: 60, color: AppColors.saffron),
            const SizedBox(height: 12),
            const Text('लोड नहीं हो सका', style: TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(contentListProvider(categoryId)),
              child: const Text('पुनः प्रयास करें'),
            ),
          ]),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.folder_open, size: 72, color: AppColors.saffron),
                SizedBox(height: 12),
                Text('कोई सामग्री नहीं मिली', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              ]),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(contentListProvider(categoryId)),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (ctx, i) => _ContentTile(content: items[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmer() => Shimmer.fromColors(
    baseColor: Colors.grey.shade200,
    highlightColor: Colors.grey.shade100,
    child: ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 8,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(height: 14, width: double.infinity, color: Colors.white),
            const SizedBox(height: 6),
            Container(height: 12, width: 140, color: Colors.white),
          ])),
        ]),
      ),
    ),
  );
}

class _ContentTile extends StatelessWidget {
  final ContentModel content;
  const _ContentTile({required this.content});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: content.imageUrl != null
          ? CachedNetworkImage(
              imageUrl: content.imageUrl!,
              width: 56, height: 56,
              fit: BoxFit.cover,
              placeholder: (_, __) => _placeholder(),
              errorWidget: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
      ),
      title: Text(
        content.title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: content.author != null
        ? Text(content.author!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
        : null,
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        _typeChip(content.type),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ]),
      onTap: () => _open(context, content),
    );
  }

  Widget _placeholder() => Container(
    width: 56, height: 56,
    color: AppColors.saffronLight,
    child: Icon(_iconForType(content.type), color: AppColors.saffron, size: 28),
  );

  Widget _typeChip(String type) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: _colorForType(type).withOpacity(.12),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      type.toUpperCase(),
      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _colorForType(type)),
    ),
  );

  void _open(BuildContext ctx, ContentModel c) {
    switch (c.type) {
      case 'pdf':
        if (c.fileUrl != null) ctx.push('/pdf', extra: c.fileUrl);
        break;
      case 'audio':
        ctx.push('/audio', extra: c.id);
        break;
      case 'video':
        if (c.fileUrl != null) ctx.push('/video', extra: c.fileUrl);
        break;
      default:
        break;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'pdf':   return Icons.picture_as_pdf;
      case 'audio': return Icons.headphones;
      case 'video': return Icons.play_circle_outline;
      case 'image': return Icons.image_outlined;
      default:      return Icons.article_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'pdf':   return AppColors.error;
      case 'audio': return AppColors.navy;
      case 'video': return AppColors.forest;
      case 'image': return AppColors.gold;
      default:      return AppColors.textSecondary;
    }
  }
}

