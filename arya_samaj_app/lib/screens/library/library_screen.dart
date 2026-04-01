import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/services/cache_service.dart';
import '../../models/content_model.dart';

// ── Paginated Library Provider ──────────────────────────────────────────────

class LibraryState {
  final List<ContentModel> items;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isLoading;
  final String? error;

  const LibraryState({
    this.items = const [],
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isLoading = false,
    this.error,
  });

  LibraryState copyWith({
    List<ContentModel>? items,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isLoading,
    String? error,
  }) =>
      LibraryState(
        items: items ?? this.items,
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  final notifier = LibraryNotifier(ref.read(apiClientProvider));
  notifier.loadMore(); // initial load
  return notifier;
});

class LibraryNotifier extends StateNotifier<LibraryState> {
  final ApiClient _api;
  static const _cacheKey = 'library_page_1';

  LibraryNotifier(this._api) : super(const LibraryState());

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    final nextPage = state.currentPage + 1;

    if (nextPage == 1) {
      state = state.copyWith(isLoading: true, error: null);
      // Try cache for first page
      final cached = CacheService.get(_cacheKey) as List?;
      if (cached != null) {
        state = state.copyWith(
          isLoading: false,
          items: cached.map((e) => ContentModel.fromJson(e as Map<String, dynamic>)).toList(),
          currentPage: 1,
          hasMore: true, // may have more pages; allow loading
        );
      }
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final res = await _api.get(ApiEndpoints.contents, params: {'type': 'pdf', 'page': nextPage});
      final list = (res.data['data'] as List).map((e) => ContentModel.fromJson(e as Map<String, dynamic>)).toList();
      final pagination = res.data['pagination'] as Map;
      final lastPage = pagination['last_page'] as int;

      if (nextPage == 1) {
        // Cache first page
        await CacheService.set(_cacheKey, res.data['data']);
      }

      state = state.copyWith(
        items: nextPage == 1 ? list : [...state.items, ...list],
        currentPage: nextPage,
        hasMore: nextPage < lastPage,
        isLoading: false,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: state.currentPage == 0 ? 'लोड नहीं हो सका' : null,
      );
    }
  }

  Future<void> refresh() async {
    state = const LibraryState();
    await loadMore();
  }
}

// ── LibraryScreen ────────────────────────────────────────────────────────────

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      ref.read(libraryProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(libraryProvider);
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
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.saffron))
              : state.error != null && state.items.isEmpty
                  ? Center(child: ElevatedButton(
                      onPressed: () => ref.read(libraryProvider.notifier).refresh(),
                      child: const Text('पुनः प्रयास करें')))
                  : RefreshIndicator(
                      onRefresh: () => ref.read(libraryProvider.notifier).refresh(),
                      child: ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(10),
                        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (ctx, i) {
                          if (i == state.items.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(color: AppColors.saffron),
                              ),
                            );
                          }
                          final b = state.items[i];
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
