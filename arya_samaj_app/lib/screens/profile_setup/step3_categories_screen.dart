import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/members_provider.dart';
import '../../providers/profile_setup_provider.dart';

class Step3CategoriesScreen extends ConsumerStatefulWidget {
  const Step3CategoriesScreen({super.key});

  @override
  ConsumerState<Step3CategoriesScreen> createState() => _Step3CategoriesScreenState();
}

class _Step3CategoriesScreenState extends ConsumerState<Step3CategoriesScreen> {
  late final TextEditingController _orgTypeCtrl;
  late final TextEditingController _orgNameCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(profileSetupProvider);
    _orgTypeCtrl = TextEditingController(text: s.orgType);
    _orgNameCtrl = TextEditingController(text: s.orgName);
  }

  @override
  void dispose() {
    _orgTypeCtrl.dispose();
    _orgNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final s = ref.read(profileSetupProvider);
    if (s.selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कम से कम एक श्रेणी चुनें'), backgroundColor: AppColors.error));
      return;
    }
    ref.read(profileSetupProvider.notifier).update((st) => st.copyWith(
      orgType: _orgTypeCtrl.text.trim(),
      orgName: _orgNameCtrl.text.trim(),
    ));
    final ok = await ref.read(profileSetupProvider.notifier).submitCategories();
    if (!ok && mounted) {
      final err = ref.read(profileSetupProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Error'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state      = ref.watch(profileSetupProvider);
    final catsAsync  = ref.watch(memberCategoriesProvider);
    final loading    = state.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('अपनी भूमिका / संबद्धता चुनें', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          catsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
            error: (e, _) => Text('लोड नहीं हुआ: $e'),
            data: (cats) {
              final roles = cats.where((c) => c.group == 'role').toList();
              final orgs  = cats.where((c) => c.group == 'org').toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _groupLabel('भूमिकाएं'),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: roles.map((c) {
                      final sel = state.selectedCategoryIds.contains(c.id);
                      return FilterChip(
                        label: Text(c.name),
                        selected: sel,
                        onSelected: (_) => _toggle(c.id, state),
                        selectedColor: AppColors.saffronLight,
                        checkmarkColor: AppColors.saffron,
                        labelStyle: TextStyle(color: sel ? AppColors.saffron : AppColors.textPrimary),
                        side: BorderSide(color: sel ? AppColors.saffron : AppColors.border),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _groupLabel('संस्था प्रकार'),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: orgs.map((c) {
                      final sel = state.selectedCategoryIds.contains(c.id);
                      return FilterChip(
                        label: Text(c.name),
                        selected: sel,
                        onSelected: (_) => _toggle(c.id, state),
                        selectedColor: AppColors.forestLight,
                        checkmarkColor: AppColors.forest,
                        labelStyle: TextStyle(color: sel ? AppColors.forest : AppColors.textPrimary),
                        side: BorderSide(color: sel ? AppColors.forest : AppColors.border),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _orgTypeCtrl,
            decoration: _dec('संस्था का प्रकार (वैकल्पिक)', Icons.business_outlined),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _orgNameCtrl,
            decoration: _dec('संस्था का नाम (वैकल्पिक)', Icons.apartment),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.saffron,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Text('आगे बढ़ें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  void _toggle(int id, ProfileSetupState s) {
    final list = List<int>.from(s.selectedCategoryIds);
    list.contains(id) ? list.remove(id) : list.add(id);
    ref.read(profileSetupProvider.notifier).update((st) => st.copyWith(selectedCategoryIds: list));
  }

  Widget _groupLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
  );

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: AppColors.saffron),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.saffron, width: 2),
    ),
  );
}
