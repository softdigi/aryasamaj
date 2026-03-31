import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _ac, curve: Curves.elasticOut));
    _ac.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      final profileComplete = prefs.getBool('profile_complete') ?? false;
      if (context.mounted) context.go(profileComplete ? '/home' : '/profile-setup');
    } else {
      if (context.mounted) context.go('/login');
    }
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.saffron, Color(0xFFBB4400), AppColors.forest],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.15),
                  border: Border.all(color: Colors.white.withOpacity(.4), width: 3),
                ),
                child: const Center(child: Text('🕉', style: TextStyle(fontSize: 70))),
              ),
              const SizedBox(height: 24),
              const Text('आर्य समाज', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 6),
              const Text('कृण्वन्तो विश्वमार्यम्', style: TextStyle(fontSize: 16, color: Colors.white70)),
            ]),
          ),
        ),
      ),
    );
  }
}
