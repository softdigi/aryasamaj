import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/feature_model.dart';
import '../models/category_model.dart';
import '../models/donation_model.dart';

final homeProvider = FutureProvider<HomeData>((ref) async {
  final api = ref.read(apiClientProvider);
  final res = await api.get(ApiEndpoints.home);
  final data = res.data['data'];
  return HomeData(
    sangathan: (data['features_sangathan'] as List).map((e) => FeatureModel.fromJson(e)).toList(),
    suvidha:   (data['features_suvidha']   as List).map((e) => FeatureModel.fromJson(e)).toList(),
    topCategories: (data['top_categories'] as List).map((e) => CategoryModel.fromJson(e)).toList(),
    donation: data['donation'] != null ? DonationModel.fromJson(data['donation']) : null,
  );
});

class HomeData {
  final List<FeatureModel> sangathan;
  final List<FeatureModel> suvidha;
  final List<CategoryModel> topCategories;
  final DonationModel? donation;
  HomeData({required this.sangathan, required this.suvidha, required this.topCategories, this.donation});
}
