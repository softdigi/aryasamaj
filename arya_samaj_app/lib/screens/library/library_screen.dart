import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../models/content_model.dart';

final libraryProvider = FutureProvider<List<ContentModel>>((ref) async {
  final api = ref.read(apiClientProvider);
  final res = await api.get(ApiEndpoints.contents, params: {'type': 'pdf'});
  return (res.data['data'] as List).map((e) => ContentModel.fromJson(e)).toList();
});

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(libraryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('पुस्तकालय'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () => context.push('/search'))],
      ),
      body: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.categoryBar,
          child: Row(children: [
            const Expanded(child: Text('पुस्तकों की पीडीएफ अपलोड करें', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.lock, color: Colors.white, size: 16),
            ),
          ]),
        ),
        Expanded(
          child: booksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
            error: (e, _) => Center(child: ElevatedButton(onPressed: () => ref.invalidate(libraryProvider), child: const Text('पुनः प्रयास करें'))),
            data: (books) => ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: books.length,
              itemBuilder: (ctx, i) {
                final b = books[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFE8F5A3), Color(0xFFF9FBD3)]),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD4E157).withOpacity(.5)),
                  ),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
                      child: b.imageUrl != null
                        ? CachedNetworkImage(imageUrl: b.imageUrl!, width: 80, height: 90, fit: BoxFit.cover)
                        : Container(width: 80, height: 90, color: AppColors.saffron.withOpacity(.2), child: const Icon(Icons.book, size: 40, color: AppColors.saffron)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(b.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      if (b.author != null) Text('-${b.author}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ])),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('PDF\nडाउनलोड', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () { if (b.fileUrl != null) context.push('/pdf', extra: b.fileUrl); },
                          child: Container(
                            width: 36, height: 36,
                            decoration: const BoxDecoration(color: AppColors.textPrimary, shape: BoxShape.circle),
                            child: const Icon(Icons.download, color: Colors.white, size: 20),
                          ),
                        ),
                      ]),
                    ),
                  ]),
                );
              },
            ),
          ),
        ),
      ]),
    );
  }
}
