import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/profile_setup_provider.dart';

class Step1BasicScreen extends ConsumerStatefulWidget {
  const Step1BasicScreen({super.key});

  @override
  ConsumerState<Step1BasicScreen> createState() => _Step1BasicScreenState();
}

class _Step1BasicScreenState extends ConsumerState<Step1BasicScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _dobCtrl;
  final _nameFocus     = FocusNode();
  final _usernameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final s = ref.read(profileSetupProvider);
    _nameCtrl     = TextEditingController(text: s.name);
    _usernameCtrl = TextEditingController(text: s.username);
    _dobCtrl      = TextEditingController(text: s.dob);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _dobCtrl.dispose();
    _nameFocus.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      ref.read(profileSetupProvider.notifier).update(
          (s) => s.copyWith(profileImageFile: File(picked.path)));
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 5),
      helpText: 'जन्म तिथि चुनें',
    );
    if (picked != null) {
      final formatted = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      _dobCtrl.text = formatted;
      ref.read(profileSetupProvider.notifier).update((s) => s.copyWith(dob: formatted));
    }
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(profileSetupProvider.notifier).update((s) => s.copyWith(
      name: _nameCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      dob: _dobCtrl.text.trim(),
      currentStep: 2,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileSetupProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.saffronLight,
                backgroundImage: state.profileImageFile != null
                    ? FileImage(state.profileImageFile!) as ImageProvider
                    : null,
                child: state.profileImageFile == null
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                        Icon(Icons.camera_alt, color: AppColors.saffron, size: 28),
                        SizedBox(height: 4),
                        Text('फोटो', style: TextStyle(fontSize: 12, color: AppColors.saffron)),
                      ])
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            _field(_nameCtrl, 'पूरा नाम', Icons.person_outline,
                focusNode: _nameFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).requestFocus(_usernameFocus),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'नाम आवश्यक है' : null),
            const SizedBox(height: 16),
            _field(_usernameCtrl, 'यूज़रनेम (अंग्रेज़ी)', Icons.alternate_email,
                focusNode: _usernameFocus,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                validator: (v) {
              if (v == null || v.trim().isEmpty) return 'यूज़रनेम आवश्यक है';
              if (!RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(v.trim())) return 'केवल अक्षर, अंक, _, - allowed';
              return null;
            }),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: state.gender,
              decoration: _dec('लिंग', Icons.wc),
              items: const [
                DropdownMenuItem(value: 'male',   child: Text('पुरुष')),
                DropdownMenuItem(value: 'female', child: Text('महिला')),
                DropdownMenuItem(value: 'other',  child: Text('अन्य')),
              ],
              onChanged: (v) => ref.read(profileSetupProvider.notifier).update((s) => s.copyWith(gender: v)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dobCtrl,
              readOnly: true,
              onTap: _pickDob,
              decoration: _dec('जन्म तिथि', Icons.calendar_today),
              validator: (v) => v == null || v.trim().isEmpty ? 'जन्म तिथि आवश्यक है' : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.saffron,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('आगे बढ़ें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    FocusNode? focusNode,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onSubmitted,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmitted,
        decoration: _dec(label, icon),
        validator: validator,
      );

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.saffron),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.saffron, width: 2),
        ),
      );
}
