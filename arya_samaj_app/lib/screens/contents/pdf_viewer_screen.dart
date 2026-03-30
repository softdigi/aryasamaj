import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PdfViewerScreen extends StatelessWidget {
  final String url;
  const PdfViewerScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF देखें')),
      body: Center(
        child: Text('PDF: $url', style: const TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
