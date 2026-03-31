import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/profile_setup_provider.dart';

class Step2AddressScreen extends ConsumerStatefulWidget {
  const Step2AddressScreen({super.key});

  @override
  ConsumerState<Step2AddressScreen> createState() => _Step2AddressScreenState();
}

class _Step2AddressScreenState extends ConsumerState<Step2AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _stateCtrl;
  late final TextEditingController _districtCtrl;
  late final TextEditingController _tehsilCtrl;
  late final TextEditingController _villageCtrl;
  late final TextEditingController _postOfficeCtrl;
  late final TextEditingController _pincodeCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(profileSetupProvider);
    _stateCtrl      = TextEditingController(text: s.state);
    _districtCtrl   = TextEditingController(text: s.district);
    _tehsilCtrl     = TextEditingController(text: s.tehsil);
    _villageCtrl    = TextEditingController(text: s.village);
    _postOfficeCtrl = TextEditingController(text: s.postOffice);
    _pincodeCtrl    = TextEditingController(text: s.pincode);
  }

  @override
  void dispose() {
    for (final c in [_stateCtrl, _districtCtrl, _tehsilCtrl, _villageCtrl, _postOfficeCtrl, _pincodeCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(profileSetupProvider.notifier);
    notifier.update((s) => s.copyWith(
      state:      _stateCtrl.text.trim(),
      district:   _districtCtrl.text.trim(),
      tehsil:     _tehsilCtrl.text.trim(),
      village:    _villageCtrl.text.trim(),
      postOffice: _postOfficeCtrl.text.trim(),
      pincode:    _pincodeCtrl.text.trim(),
    ));
    await notifier.submitBasicAndAddress();
    final error = ref.read(profileSetupProvider).error;
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(profileSetupProvider).isLoading;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _field(_stateCtrl, 'राज्य *', Icons.map_outlined, required: true),
            const SizedBox(height: 16),
            _field(_districtCtrl, 'जिला *', Icons.location_city, required: true),
            const SizedBox(height: 16),
            _field(_tehsilCtrl, 'तहसील', Icons.place_outlined),
            const SizedBox(height: 16),
            _field(_villageCtrl, 'गाँव / मोहल्ला', Icons.home_outlined),
            const SizedBox(height: 16),
            _field(_postOfficeCtrl, 'पोस्ट ऑफिस', Icons.mail_outline),
            const SizedBox(height: 16),
            _field(_pincodeCtrl, 'पिन कोड', Icons.pin_outlined,
                keyboard: TextInputType.number),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.saffron,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text('सेव करें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {bool required = false, TextInputType? keyboard}) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.saffron),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.saffron, width: 2),
          ),
        ),
        validator: required
            ? (v) => v == null || v.trim().isEmpty ? 'यह फ़ील्ड आवश्यक है' : null
            : null,
      );
}
