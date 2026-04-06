import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/services/cache_service.dart';
import '../models/feature_model.dart';
import '../models/category_model.dart';
import '../models/donation_model.dart';

/// True when the last home load came from the Hive cache (no network).
final homeOfflineProvider = StateProvider<bool>((ref) => false);

final homeProvider = FutureProvider<HomeData>((ref) async {
  const cacheKey = 'home_data';
  final api = ref.read(apiClientProvider);

  try {
    final res = await api.get(ApiEndpoints.home);
    final data = res.data['data'];
    final home = HomeData(
      sangathan: (data['features_sangathan'] as List).map((e) => FeatureModel.fromJson(e)).toList(),
      suvidha:   (data['features_suvidha']   as List).map((e) => FeatureModel.fromJson(e)).toList(),
      topCategories: (data['top_categories'] as List).map((e) => CategoryModel.fromJson(e)).toList(),
      donation: data['donation'] != null ? DonationModel.fromJson(data['donation']) : null,
    );
    // Persist to cache
    await CacheService.set(cacheKey, data);
    ref.read(homeOfflineProvider.notifier).state = false;
    return home;
  } catch (_) {
    // Fallback to cache
    final cached = CacheService.get(cacheKey);
    if (cached != null) {
      ref.read(homeOfflineProvider.notifier).state = true;
      return HomeData(
        sangathan: (cached['features_sangathan'] as List).map((e) => FeatureModel.fromJson(e as Map<String, dynamic>)).toList(),
        suvidha:   (cached['features_suvidha']   as List).map((e) => FeatureModel.fromJson(e as Map<String, dynamic>)).toList(),
        topCategories: (cached['top_categories'] as List).map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList(),
        donation: cached['donation'] != null ? DonationModel.fromJson(cached['donation']) : null,
      );
    }
    rethrow;
  }
});

class HomeData {
  final List<FeatureModel> sangathan;
  final List<FeatureModel> suvidha;
  final List<CategoryModel> topCategories;
  final DonationModel? donation;
  HomeData({required this.sangathan, required this.suvidha, required this.topCategories, this.donation});
}
