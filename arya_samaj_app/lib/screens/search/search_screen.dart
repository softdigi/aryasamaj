import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../models/content_model.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.family<List<ContentModel>, String>((ref, query) async {
  if (query.trim().length < 2) return [];
  final api = ref.read(apiClientProvider);
  final res = await api.get(ApiEndpoints.contents, params: {'search': query.trim()});
  return (res.data['data'] as List).map((e) => ContentModel.fromJson(e)).toList();
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    ref.read(_searchQueryProvider.notifier).state = v;
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(_searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: 'खोजें...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white.withOpacity(.7)),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _ctrl.clear();
                ref.read(_searchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: query.trim().length < 2
          ? _emptyState()
          : resultsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
              error: (e, _) => const Center(child: Text('खोज नहीं हो सकी')),
              data: (results) => results.isEmpty
                  ? _noResults(query)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                      itemBuilder: (ctx, i) => _resultTile(ctx, results[i]),
                    ),
            ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.search, size: 72, color: AppColors.saffron.withOpacity(.4)),
      const SizedBox(height: 12),
      const Text('कम से कम 2 अक्षर लिखें', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
    ]),
  );

  Widget _noResults(String query) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.search_off, size: 72, color: Colors.grey.shade300),
      const SizedBox(height: 12),
      Text('"$query" के लिए कोई परिणाम नहीं', style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
    ]),
  );

  Widget _resultTile(BuildContext ctx, ContentModel c) {
    final icon = _iconForType(c.type);
    return ListTile(
      leading: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.saffron.withOpacity(.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.saffron, size: 22),
      ),
      title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: c.author != null ? Text(c.author!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)) : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: () => _openContent(ctx, c),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'pdf':   return Icons.picture_as_pdf;
      case 'audio': return Icons.headphones;
      case 'video': return Icons.play_circle_outline;
      case 'image': return Icons.image_outlined;
      default:      return Icons.article_outlined;
    }
  }

  void _openContent(BuildContext ctx, ContentModel c) {
    switch (c.type) {
      case 'pdf':
        if (c.fileUrl != null) ctx.push('/pdf', extra: c.fileUrl);
        break;
      case 'audio':
        ctx.push('/audio', extra: c.id);
        break;
      case 'video':
        if (c.fileUrl != null) ctx.push('/video', extra: c.fileUrl);
        break;
      default:
        break;
    }
  }
}
