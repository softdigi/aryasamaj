import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/profile_setup_provider.dart';
import '../../providers/auth_provider.dart';

class Step5ImagesScreen extends ConsumerStatefulWidget {
  const Step5ImagesScreen({super.key});

  @override
  ConsumerState<Step5ImagesScreen> createState() => _Step5ImagesScreenState();
}

class _Step5ImagesScreenState extends ConsumerState<Step5ImagesScreen> {
  final List<File> _picked = [];

  Future<void> _addImages() async {
    final images = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      setState(() {
        _picked.addAll(images.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _submit() async {
    if (_picked.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कम से कम 1 फोटो चुनें'), backgroundColor: AppColors.error));
      return;
    }
    final ok = await ref.read(profileSetupProvider.notifier).submitImages(_picked);
    if (ok) {
      await ref.read(authProvider.notifier).markProfileComplete();
    } else if (mounted) {
      final err = ref.read(profileSetupProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Error'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state   = ref.watch(profileSetupProvider);
    final loading = state.isLoading;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('प्रोफाइल फोटो गैलरी', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          const Text('अपने कार्यक्रमों, गुरुकुल या आर्य समाज गतिविधियों की फोटो अपलोड करें।',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: _picked.length + 1,
              itemBuilder: (ctx, i) {
                if (i == _picked.length) {
                  return GestureDetector(
                    onTap: _addImages,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.saffronLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.saffron, style: BorderStyle.solid),
                      ),
                      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_photo_alternate, color: AppColors.saffron, size: 32),
                        SizedBox(height: 4),
                        Text('जोड़ें', style: TextStyle(fontSize: 12, color: AppColors.saffron)),
                      ]),
                    ),
                  );
                }
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_picked[i], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    ),
                    Positioned(
                      top: 2, right: 2,
                      child: GestureDetector(
                        onTap: () => setState(() => _picked.removeAt(i)),
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forest,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Text('प्रोफाइल पूरी करें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
