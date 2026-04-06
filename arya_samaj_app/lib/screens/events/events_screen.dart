import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../models/event_model.dart';

// ── Paginated Events Provider ─────────────────────────────────────────────────

class EventsState {
  final List<EventModel> items;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isLoading;
  final String filter;
  final String? error;

  const EventsState({
    this.items = const [],
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isLoading = false,
    this.filter = 'all',
    this.error,
  });

  EventsState copyWith({
    List<EventModel>? items,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isLoading,
    String? filter,
    String? error,
  }) =>
      EventsState(
        items: items ?? this.items,
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isLoading: isLoading ?? this.isLoading,
        filter: filter ?? this.filter,
        error: error,
      );
}

final eventsProvider = StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  final notifier = EventsNotifier(ref.read(apiClientProvider));
  notifier.loadMore();
  return notifier;
});

class EventsNotifier extends StateNotifier<EventsState> {
  final ApiClient _api;

  EventsNotifier(this._api) : super(const EventsState());

  Future<void> changeFilter(String filter) async {
    state = EventsState(filter: filter);
    await loadMore();
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    final nextPage = state.currentPage + 1;

    if (nextPage == 1) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final params = <String, dynamic>{'page': nextPage};
      if (state.filter != 'all') params['filter'] = state.filter;

      final res = await _api.get(ApiEndpoints.events, params: params);
      final list = (res.data['data'] as List)
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = res.data['pagination'] as Map;
      final lastPage = pagination['last_page'] as int;

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
    state = EventsState(filter: state.filter);
    await loadMore();
  }
}

// ── EventsScreen ─────────────────────────────────────────────────────────────

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final _scroll = ScrollController();
  static const _filters = [
    ('all', 'सभी'),
    ('upcoming', 'आगामी'),
    ('past', 'पुराने'),
  ];

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
      ref.read(eventsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('आर्य समाज के कार्यक्रम')),
      body: Column(children: [
        Container(
          color: AppColors.categoryBar,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: _filters.map((f) {
                final k = f.$1;
                final label = f.$2;
                return GestureDetector(
                  onTap: () {
                    if (state.filter != k) {
                      ref.read(eventsProvider.notifier).changeFilter(k);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: state.filter == k ? AppColors.saffron : Colors.white.withOpacity(.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(label,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.saffron))
              : state.error != null && state.items.isEmpty
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text('लोड नहीं हो सका'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref.read(eventsProvider.notifier).refresh(),
                          child: const Text('पुनः प्रयास करें'),
                        ),
                      ]),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(eventsProvider.notifier).refresh(),
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
                          return _EventCard(event: state.items[i]);
                        },
                      ),
                    ),
        ),
      ]),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy, hh:mm a', 'en_IN');
    final isUpcoming = event.status == 'upcoming';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (event.imageUrl != null)
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            child: CachedNetworkImage(
              imageUrl: event.imageUrl!,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            width: double.infinity,
            height: 100,
            decoration: const BoxDecoration(
              color: AppColors.saffronLight,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
            child: const Icon(Icons.event, size: 52, color: AppColors.saffron),
          ),

        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isUpcoming ? AppColors.forestLight : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isUpcoming ? 'आगामी' : 'पुराना',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isUpcoming ? AppColors.forest : AppColors.textSecondary),
                ),
              ),
              const Spacer(),
              if (event.location != null)
                Row(children: [
                  const Icon(Icons.location_on, size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 2),
                  Text(event.location!,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ]),
            ]),
            const SizedBox(height: 8),
            Text(event.title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            if (event.description != null && event.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(event.description!,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.calendar_today, size: 13, color: AppColors.saffron),
              const SizedBox(width: 4),
              Text(
                event.eventDate != null ? df.format(event.eventDate!) : '—',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.saffron),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}
