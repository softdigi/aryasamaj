import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/services/cache_service.dart';
import '../models/category_model.dart';

final categoryProvider = FutureProvider.family<List<CategoryModel>, int?>((ref, parentId) async {
  final cacheKey = 'categories_${parentId ?? 'root'}';
  final api = ref.read(apiClientProvider);

  try {
    final res = await api.get(ApiEndpoints.categories, params: parentId != null ? {'parent_id': parentId} : {});
    final list = res.data['data'] as List;
    await CacheService.set(cacheKey, list);
    return list.map((e) => CategoryModel.fromJson(e)).toList();
  } catch (_) {
    final cached = CacheService.get(cacheKey) as List?;
    if (cached != null) {
      return cached.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    rethrow;
  }
});
