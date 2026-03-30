import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/category_model.dart';

final categoryProvider = FutureProvider.family<List<CategoryModel>, int?>((ref, parentId) async {
  final api = ref.read(apiClientProvider);
  final res = await api.get(ApiEndpoints.categories, params: parentId != null ? {'parent_id': parentId} : {});
  return (res.data['data'] as List).map((e) => CategoryModel.fromJson(e)).toList();
});
