import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String mobile;
  const OtpScreen({super.key, required this.mobile});
  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  int _seconds = 60;
  Timer? _timer;
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) { t.cancel(); return; }
      setState(() => _seconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(title: const Text('OTP सत्यापन')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 32),
          Text('+91 ${widget.mobile}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('पर OTP भेजा गया है', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 40),
          Pinput(
            length: 6,
            onCompleted: (pin) => setState(() => _otp = pin),
            defaultPinTheme: PinTheme(
              width: 52, height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.saffron.withOpacity(.4)),
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 32),
          if (auth.error != null)
            Text(auth.error!, style: const TextStyle(color: Color(0xFFC62828))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: (_otp.length == 6 && !auth.isLoading) ? () async {
              final ok = await ref.read(authProvider.notifier).verifyOtp(widget.mobile, _otp);
              if (ok && context.mounted) context.go('/home');
            } : null,
            child: auth.isLoading
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : const Text('सत्यापित करें'),
          ),
          const SizedBox(height: 20),
          _seconds > 0
            ? Text('OTP resend: $_seconds सेकंड', style: const TextStyle(color: AppColors.textSecondary))
            : TextButton(
                onPressed: () {
                  ref.read(authProvider.notifier).sendOtp(widget.mobile);
                  _startTimer();
                },
                child: const Text('OTP फिर भेजें', style: TextStyle(color: AppColors.saffron, fontWeight: FontWeight.w700)),
              ),
        ]),
      ),
    );
  }
}
