import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/category_provider.dart';

class CategoryScreen extends ConsumerWidget {
  final int? parentId;
  final String title;
  const CategoryScreen({super.key, this.parentId, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(categoryProvider(parentId));
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: cats.when(
        loading: () => _shimmer(),
        error: (e, _) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.wifi_off, size: 48, color: AppColors.saffron),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => ref.invalidate(categoryProvider(parentId)), child: const Text('पुनः प्रयास करें')),
        ])),
        data: (list) => GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 0.9, crossAxisSpacing: 10, mainAxisSpacing: 10,
          ),
          itemCount: list.length,
          itemBuilder: (ctx, i) {
            final cat = list[i];
            return GestureDetector(
              onTap: () {
                if (cat.hasChild) {
                  context.push('/categories', extra: {'parent_id': cat.id, 'title': cat.name});
                } else {
                  context.push('/contents', extra: {'category_id': cat.id, 'title': cat.name});
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.saffron.withOpacity(.15)),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: cat.icon != null
                      ? Image.network(cat.icon!, width: 56, height: 56, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(width: 56, height: 56, color: AppColors.saffronLight, child: const Icon(Icons.folder, color: AppColors.saffron, size: 32)))
                      : Container(width: 56, height: 56, color: AppColors.saffronLight, child: const Icon(Icons.folder, color: AppColors.saffron, size: 32)),
                  ),
                  const SizedBox(height: 8),
                  Text(cat.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  if (cat.hasChild)
                    const Icon(Icons.chevron_right, size: 14, color: AppColors.textMuted),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _shimmer() => Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, childAspectRatio: 0.9, crossAxisSpacing: 10, mainAxisSpacing: 10,
      ),
      itemCount: 9,
      itemBuilder: (c, i) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
    ),
  );
}

