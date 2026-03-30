import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.saffron, Color(0xFFCC4400), AppColors.forest],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            const Spacer(),
            Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.15),
                border: Border.all(color: Colors.white.withOpacity(.3), width: 2),
              ),
              child: const Center(child: Text('🕉', style: TextStyle(fontSize: 54))),
            ),
            const SizedBox(height: 16),
            const Text('आर्य समाज', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white)),
            const Text('कृण्वन्तो विश्वमार्यम्', style: TextStyle(fontSize: 14, color: Colors.white70)),
            const Spacer(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('मोबाइल नंबर', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ctrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    hintText: '10 अंकों का नंबर',
                    prefixText: '+91 ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.saffron, width: 2),
                    ),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 16),
                if (auth.error != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(8)),
                    child: Text(auth.error!, style: const TextStyle(color: Color(0xFFC62828), fontSize: 13)),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: auth.isLoading ? null : () async {
                    if (_ctrl.text.length != 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('10 अंकों का नंबर दर्ज करें')),
                      );
                      return;
                    }
                    final ok = await ref.read(authProvider.notifier).sendOtp(_ctrl.text);
                    if (ok && context.mounted) context.push('/otp', extra: _ctrl.text);
                  },
                  child: auth.isLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text('OTP भेजें'),
                ),
              ]),
            ),
            const Spacer(),
          ]),
        ),
      ),
    );
  }
}
