import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';

class DonationScreen extends ConsumerWidget {
  const DonationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('सहयोग करें')),
      body: const Center(child: Text('Donation', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
