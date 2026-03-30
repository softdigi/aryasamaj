import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AudioPlayerScreen extends StatelessWidget {
  final int categoryId;
  const AudioPlayerScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ऑडियो')),
      body: Center(
        child: Text('Audio — categoryId: $categoryId', style: const TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
