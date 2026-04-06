import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../models/content_model.dart';
import '../../models/category_model.dart';
import '../../models/member_user_model.dart';

// ── Data model for unified search results ────────────────────────────────────

class SearchResults {
  final List<ContentModel> contents;
  final List<CategoryModel> categories;
  final List<MemberUserModel> members;

  const SearchResults({
    this.contents = const [],
    this.categories = const [],
    this.members = const [],
  });

  bool get isEmpty => contents.isEmpty && categories.isEmpty && members.isEmpty;
}

// ── Provider ─────────────────────────────────────────────────────────────────

final _searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider =
    FutureProvider.family<SearchResults, String>((ref, query) async {
  if (query.trim().length < 2) return const SearchResults();
  final api = ref.read(apiClientProvider);
  final res = await api.get(ApiEndpoints.search, params: {'q': query.trim()});
  final data = res.data['data'] as Map;

  final contents = (data['contents'] as List? ?? [])
      .map((e) => ContentModel.fromJson({
            'id': e['id'],
            'title': e['title'],
            'type': e['content_type'] ?? 'text',
            'image_url': e['image_url'],
            'author': e['author'],
          }))
      .toList();

  final categories = (data['categories'] as List? ?? [])
      .map((e) => CategoryModel.fromJson({
            'id': e['id'],
            'name': e['title'],
            'has_child': e['has_child'] ?? false,
          }))
      .toList();

  final members = (data['members'] as List? ?? [])
      .map((e) => MemberUserModel.fromJson({
            'id': e['id'],
            'name': e['title'],
            'username': e['username'],
            'state': e['state'],
            'district': e['district'],
            'profile_image': e['profile_image'],
          }))
      .toList();

  return SearchResults(
    contents: contents,
    categories: categories,
    members: members,
  );
});

// ── Screen ────────────────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    if (v.trim().length < 2) {
      ref.read(_searchQueryProvider.notifier).state = '';
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(_searchQueryProvider.notifier).state = v;
    });
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
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.saffron)),
              error: (e, _) => const Center(child: Text('खोज नहीं हो सकी')),
              data: (results) => results.isEmpty
                  ? _noResults(query)
                  : _ResultsView(results: results),
            ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search, size: 72,
              color: AppColors.saffron.withOpacity(.4)),
          const SizedBox(height: 12),
          const Text('कम से कम 2 अक्षर लिखें',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 16)),
        ]),
      );

  Widget _noResults(String q) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search_off, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('"$q" के लिए कोई परिणाम नहीं',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 15)),
        ]),
      );
}

// ── Results view (sectioned) ─────────────────────────────────────────────────

class _ResultsView extends StatelessWidget {
  final SearchResults results;
  const _ResultsView({required this.results});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (results.contents.isNotEmpty) ...[
          _sectionHeader('सामग्री', Icons.library_books_outlined, results.contents.length),
          ...results.contents.map((c) => _ContentResultTile(content: c)),
        ],
        if (results.categories.isNotEmpty) ...[
          _sectionHeader('श्रेणियां', Icons.category_outlined, results.categories.length),
          ...results.categories.map((c) => _CategoryResultTile(category: c)),
        ],
        if (results.members.isNotEmpty) ...[
          _sectionHeader('सदस्य', Icons.people_outline, results.members.length),
          ...results.members.map((m) => _MemberResultTile(member: m)),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title, IconData icon, int count) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.saffron),
          const SizedBox(width: 6),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.textPrimary)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.saffron.withOpacity(.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.saffron)),
          ),
          const Spacer(),
          Container(height: 1, width: 40, color: AppColors.border),
        ]),
      );
}

class _ContentResultTile extends StatelessWidget {
  final ContentModel content;
  const _ContentResultTile({required this.content});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildLeading(),
      title: Text(content.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis),
      subtitle: content.author != null
          ? Text(content.author!,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary))
          : null,
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        _typeChip(content.type),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ]),
      onTap: () => _open(context, content),
    );
  }

  Widget _buildLeading() {
    if (content.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: content.imageUrl!,
          width: 44, height: 44, fit: BoxFit.cover,
          placeholder: (_, __) => _placeholder(),
          errorWidget: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.saffron.withOpacity(.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(_iconForType(content.type),
            color: AppColors.saffron, size: 22),
      );

  Widget _typeChip(String type) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: _colorForType(type).withOpacity(.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          type.toUpperCase(),
          style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: _colorForType(type)),
        ),
      );

  void _open(BuildContext ctx, ContentModel c) {
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
        ctx.push('/contents/:id'.replaceFirst(':id', '${c.id}'));
        break;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'audio': return Icons.headphones;
      case 'video': return Icons.play_circle_outline;
      case 'image': return Icons.image_outlined;
      default: return Icons.article_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'pdf': return AppColors.error;
      case 'audio': return AppColors.navy;
      case 'video': return AppColors.forest;
      case 'image': return AppColors.gold;
      default: return AppColors.textSecondary;
    }
  }
}

class _CategoryResultTile extends StatelessWidget {
  final CategoryModel category;
  const _CategoryResultTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.forest.withOpacity(.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.folder_outlined,
            color: AppColors.forest, size: 22),
      ),
      title: Text(category.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (category.hasChild)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.forestLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('उपश्रेणी',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forest)),
          ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ]),
      onTap: () => context.push('/categories',
          extra: {'parent_id': category.id, 'title': category.name}),
    );
  }
}

class _MemberResultTile extends StatelessWidget {
  final MemberUserModel member;
  const _MemberResultTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.saffronLight,
        backgroundImage: member.profileImage != null
            ? CachedNetworkImageProvider(member.profileImage!)
            : null,
        child: member.profileImage == null
            ? Text(
                (member.name.isNotEmpty ? member.name[0] : '?').toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.saffron,
                    fontSize: 16),
              )
            : null,
      ),
      title: Text(member.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: (member.district != null || member.state != null)
          ? Text(
              [member.district, member.state]
                  .where((s) => s != null && s.isNotEmpty)
                  .join(', '),
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: () => context.push('/members/${member.id}'),
    );
  }
}
