import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class CategoryScreen extends ConsumerWidget {
  final int? parentId;
  final String title;
  const CategoryScreen({super.key, this.parentId, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('Categories — parent: $parentId', style: const TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
