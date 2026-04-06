import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../models/member_category_model.dart';
import '../../models/member_user_model.dart';
import '../../providers/members_provider.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(membersProvider.notifier).load(ref.read(membersFilterProvider), reset: true);
    });
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      final state = ref.read(membersProvider);
      if (!state.isLoading && state.hasMore) {
        ref.read(membersProvider.notifier).load(ref.read(membersFilterProvider));
      }
    }
  }

  void _applyFilter(MembersFilter filter) {
    ref.read(membersFilterProvider.notifier).state = filter;
    ref.read(membersProvider.notifier).load(filter, reset: true);
  }

  void _showFilterSheet() async {
    final catsAsync = ref.read(memberCategoriesProvider);
    final current = ref.read(membersFilterProvider);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FilterSheet(
        current: current,
        categories: catsAsync.valueOrNull ?? [],
        onApply: (f) {
          Navigator.pop(context);
          _applyFilter(f);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state  = ref.watch(membersProvider);
    final filter = ref.watch(membersFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.saffron,
        foregroundColor: Colors.white,
        title: const Text('सदस्य निर्देशिका'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'नाम या यूज़रनेम से खोजें',
                prefixIcon: const Icon(Icons.search, color: AppColors.saffron),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _applyFilter(filter.copyWith(search: ''));
                        })
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              onSubmitted: (v) => _applyFilter(filter.copyWith(search: v, page: 1)),
              onChanged: (v) => setState(() {}),
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(state.error!, style: const TextStyle(color: AppColors.error)),
            ),
          Expanded(
            child: state.members.isEmpty && state.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.saffron))
                : state.members.isEmpty
                    ? const Center(child: Text('कोई सदस्य नहीं मिला', style: TextStyle(color: AppColors.textSecondary)))
                    : GridView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 10, mainAxisSpacing: 10),
                        itemCount: state.members.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (ctx, i) {
                          if (i == state.members.length) {
                            return const Center(child: CircularProgressIndicator(color: AppColors.saffron, strokeWidth: 2));
                          }
                          return _MemberCard(member: state.members[i]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final MemberUserModel member;
  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final img = member.firstImage ?? member.profileImage;
    return GestureDetector(
      onTap: () => context.push('/members/${member.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: img != null
                  ? CachedNetworkImage(
                      imageUrl: img, height: 140, width: double.infinity, fit: BoxFit.cover,
                      placeholder: (_, __) => Container(height: 140, color: AppColors.saffronLight),
                      errorWidget: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(member.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      if (member.isVerified)
                        const Icon(Icons.verified, size: 16, color: AppColors.navy),
                    ],
                  ),
                  if (member.state != null) ...[
                    const SizedBox(height: 2),
                    Text('${member.state}${member.district != null ? ", ${member.district}" : ""}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                  if (member.categories.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4, runSpacing: 4,
                      children: member.categories.take(2).map((c) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.saffronLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(c.name, style: const TextStyle(fontSize: 10, color: AppColors.saffron)),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    height: 140, width: double.infinity,
    color: AppColors.saffronLight,
    child: const Icon(Icons.person, size: 56, color: AppColors.saffron),
  );
}

// ---- Filter Bottom Sheet ----
class _FilterSheet extends StatefulWidget {
  final MembersFilter current;
  final List<MemberCategoryModel> categories;
  final void Function(MembersFilter) onApply;
  const _FilterSheet({required this.current, required this.categories, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late int? _catId;
  final _stateCtrl    = TextEditingController();
  final _districtCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _catId = widget.current.categoryId;
    _stateCtrl.text    = widget.current.state ?? '';
    _districtCtrl.text = widget.current.district ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('फ़िल्टर', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          DropdownButtonFormField<int?>(
            value: _catId,
            decoration: InputDecoration(
              labelText: 'श्रेणी',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('सभी श्रेणियां')),
              ...widget.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
            ],
            onChanged: (v) => setState(() => _catId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _stateCtrl,
            decoration: InputDecoration(
              labelText: 'राज्य',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _districtCtrl,
            decoration: InputDecoration(
              labelText: 'जिला',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => widget.onApply(const MembersFilter()),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.saffron)),
                  child: const Text('रीसेट', style: TextStyle(color: AppColors.saffron)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onApply(MembersFilter(
                    categoryId: _catId,
                    state:      _stateCtrl.text.trim().isEmpty ? null : _stateCtrl.text.trim(),
                    district:   _districtCtrl.text.trim().isEmpty ? null : _districtCtrl.text.trim(),
                  )),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.saffron, foregroundColor: Colors.white),
                  child: const Text('लागू करें'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Extension for card firstImage convenience
extension _MemberExt on MemberUserModel {
  String? get firstImage => images.isNotEmpty ? images.first.url : null;
}
