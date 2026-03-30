import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';

class ContentListScreen extends ConsumerWidget {
  final int categoryId;
  final String title;
  const ContentListScreen({super.key, required this.categoryId, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('Contents — categoryId: $categoryId', style: const TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
