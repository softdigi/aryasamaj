import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/member_category_model.dart';
import '../models/member_user_model.dart';

// ---- Member Categories ----
final memberCategoriesProvider = FutureProvider<List<MemberCategoryModel>>((ref) async {
  final api = ref.read(apiClientProvider);
  final res = await api.get(ApiEndpoints.memberCategories);
  final list = res.data['data'] as List;
  return list.map((e) => MemberCategoryModel.fromJson(e as Map<String, dynamic>)).toList();
});

// ---- Members List ----
class MembersFilter {
  final int? categoryId;
  final String? state;
  final String? district;
  final String? search;
  final int page;
  const MembersFilter({this.categoryId, this.state, this.district, this.search, this.page = 1});

  MembersFilter copyWith({int? categoryId, String? state, String? district, String? search, int? page}) =>
      MembersFilter(
        categoryId: categoryId ?? this.categoryId,
        state: state ?? this.state,
        district: district ?? this.district,
        search: search ?? this.search,
        page: page ?? this.page,
      );
}

class MembersState {
  final List<MemberUserModel> members;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;
  const MembersState({
    this.members = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
  });
  MembersState copyWith({List<MemberUserModel>? members, bool? isLoading, bool? hasMore, int? currentPage, String? error}) =>
      MembersState(
        members: members ?? this.members,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        error: error,
      );
}

final membersFilterProvider = StateProvider<MembersFilter>((ref) => const MembersFilter());

final membersProvider = StateNotifierProvider<MembersNotifier, MembersState>((ref) {
  return MembersNotifier(ref.read(apiClientProvider));
});

class MembersNotifier extends StateNotifier<MembersState> {
  final ApiClient _api;
  MembersNotifier(this._api) : super(const MembersState());

  Future<void> load(MembersFilter filter, {bool reset = false}) async {
    if (state.isLoading) return;
    final page = reset ? 1 : state.currentPage;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final params = <String, dynamic>{'per_page': 20, 'page': page};
      if (filter.categoryId != null) params['category_id'] = filter.categoryId;
      if (filter.state != null && filter.state!.isNotEmpty) params['state'] = filter.state;
      if (filter.district != null && filter.district!.isNotEmpty) params['district'] = filter.district;
      if (filter.search != null && filter.search!.isNotEmpty) params['search'] = filter.search;

      final res = await _api.get(ApiEndpoints.members, params: params);
      final list = (res.data['data'] as List)
          .map((e) => MemberUserModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final meta = res.data['meta'] as Map<String, dynamic>;
      final lastPage = meta['last_page'] as int;

      state = state.copyWith(
        members: reset ? list : [...state.members, ...list],
        isLoading: false,
        hasMore: page < lastPage,
        currentPage: page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'सदस्य लोड नहीं हुए');
    }
  }
}

// ---- Member Detail ----
final memberDetailProvider = FutureProvider.family<MemberUserModel, int>((ref, id) async {
  final api = ref.read(apiClientProvider);
  final res = await api.get('${ApiEndpoints.members}/$id');
  return MemberUserModel.fromJson(res.data['data'] as Map<String, dynamic>);
});
