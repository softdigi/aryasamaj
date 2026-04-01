import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_setup_provider.dart';
import 'step1_basic_screen.dart';
import 'step2_address_screen.dart';
import 'step3_categories_screen.dart';
import 'step4_about_screen.dart';
import 'step5_images_screen.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  @override
  void initState() {
    super.initState();
    // Pre-load existing profile data for editing users
    final auth = ref.read(authProvider);
    if (auth.profileComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(profileSetupProvider.notifier).loadExistingProfile();
      });
    }
  }

  static const _titles = ['मूल जानकारी', 'पता', 'श्रेणी', 'परिचय', 'फोटो'];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileSetupProvider);
    final step = state.currentStep.clamp(1, 5);

    if (state.done) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/home');
      });
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.saffron,
        foregroundColor: Colors.white,
        title: Text('प्रोफाइल सेटअप – ${_titles[step - 1]}'),
        automaticallyImplyLeading: step > 1,
        leading: step > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => ref.read(profileSetupProvider.notifier).goToStep(step - 1),
              )
            : null,
      ),
      body: state.isLoading && step == 1
          ? const Center(child: CircularProgressIndicator(color: AppColors.saffron))
          : Column(
              children: [
                _StepIndicator(currentStep: step),
                Expanded(child: _bodyFor(step)),
              ],
            ),
    );
  }

  Widget _bodyFor(int step) {
    switch (step) {
      case 1: return const Step1BasicScreen();
      case 2: return const Step2AddressScreen();
      case 3: return const Step3CategoriesScreen();
      case 4: return const Step4AboutScreen();
      case 5: return const Step5ImagesScreen();
      default: return const SizedBox.shrink();
    }
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: List.generate(5, (i) {
          final active = i + 1 == currentStep;
          final done = i + 1 < currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: done || active ? AppColors.saffron : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < 4) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}
