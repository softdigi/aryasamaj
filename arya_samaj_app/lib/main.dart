import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';

void main() {
  runApp(const ProviderScope(child: AryaSamajApp()));
}

class AryaSamajApp extends StatelessWidget {
  const AryaSamajApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.saffron),
        scaffoldBackgroundColor: AppColors.scaffoldBg,
        fontFamily: 'NotoSansDevanagari',
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            AppStrings.appName,
            style: TextStyle(
              fontSize: 32,
              color: AppColors.saffron,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
