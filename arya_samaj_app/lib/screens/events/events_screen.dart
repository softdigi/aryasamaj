import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../models/content_model.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);
const _tabs = ['सभी', 'आर्य समाज', 'यज्ञ', 'शिविर', 'पुरोहित'];

final eventsProvider = FutureProvider<List<ContentModel>>((ref) async {
  final api = ref.read(apiClientProvider);
  final res = await api.get(ApiEndpoints.contents, params: {'type': 'image'});
  return (res.data['data'] as List).map((e) => ContentModel.fromJson(e)).toList();
});

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(selectedTabProvider);
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('आर्य समाज के कार्यक्रम')),
      body: Column(children: [
        Container(
          color: AppColors.categoryBar,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(children: List.generate(_tabs.length, (i) => GestureDetector(
              onTap: () => ref.read(selectedTabProvider.notifier).state = i,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: tab == i ? AppColors.saffron : Colors.white.withOpacity(.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_tabs[i], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ))),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(children: [
            Expanded(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(30)),
              child: const Text('पोस्ट करें', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            )),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: AppColors.saffron, borderRadius: BorderRadius.circular(20)),
              child: const Text('NEW POST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
            ),
          ]),
        ),
        Expanded(child: eventsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
          error: (e, _) => const Center(child: Text('लोड नहीं हो सका')),
          data: (events) => ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: events.length,
            itemBuilder: (ctx, i) {
              final ev = events[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                    child: ev.imageUrl != null
                      ? CachedNetworkImage(imageUrl: ev.imageUrl!, width: 90, height: 80, fit: BoxFit.cover)
                      : Container(width: 90, height: 80, color: AppColors.saffronLight, child: const Icon(Icons.event, color: AppColors.saffron, size: 36)),
                  ),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(ev.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 3, overflow: TextOverflow.ellipsis),
                  )),
                ]),
              );
            },
          ),
        )),
      ]),
    );
  }
}
