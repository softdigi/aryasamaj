import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/profile_setup_provider.dart';

class Step4AboutScreen extends ConsumerStatefulWidget {
  const Step4AboutScreen({super.key});

  @override
  ConsumerState<Step4AboutScreen> createState() => _Step4AboutScreenState();
}

class _Step4AboutScreenState extends ConsumerState<Step4AboutScreen> {
  late final TextEditingController _aboutCtrl;

  @override
  void initState() {
    super.initState();
    _aboutCtrl = TextEditingController(text: ref.read(profileSetupProvider).about);
  }

  @override
  void dispose() {
    _aboutCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final text = _aboutCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया अपना परिचय लिखें'), backgroundColor: AppColors.error));
      return;
    }
    ref.read(profileSetupProvider.notifier).update((s) => s.copyWith(about: text));
    final ok = await ref.read(profileSetupProvider.notifier).submitAbout();
    if (!ok && mounted) {
      final err = ref.read(profileSetupProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Error'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(profileSetupProvider).isLoading;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('अपना परिचय लिखें', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          const Text('आप कौन हैं, क्या करते हैं, आपकी रुचियां क्या हैं – यह सब यहाँ लिखें।',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),
          Expanded(
            child: TextFormField(
              controller: _aboutCtrl,
              maxLines: null,
              expands: true,
              maxLength: 6000,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'उदाहरण: मैं राजस्थान के जयपुर से हूँ। मैं आर्य समाज का सदस्य हूँ…',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.saffron, width: 2),
                ),
                alignLabelWithHint: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
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
}
