import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String url;
  const VideoPlayerScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('वीडियो')),
      body: Center(
        child: Text('Video: $url', style: const TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
