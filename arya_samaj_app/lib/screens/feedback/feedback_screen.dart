import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});
  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _ctrl = TextEditingController();
  String _type = 'suggestion';
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('सुझाव भेजें')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('महत्वपूर्ण सुझाव', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('आपका सहयोग हमें दोगुनी उत्साह से कार्य करने के लिए प्रोत्साहित करता है।',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),
          const Text('प्रकार', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 10, children: [
            _chip('सुझाव', 'suggestion'),
            _chip('समस्या', 'bug'),
            _chip('प्रशंसा', 'praise'),
            _chip('अन्य', 'other'),
          ]),
          const SizedBox(height: 20),
          const Text('संदेश', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'अपना सुझाव लिखें...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.saffron, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('सुझाव भेजें'),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    if (_ctrl.text.trim().length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कम से कम 5 अक्षर लिखें')));
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(apiClientProvider).post(ApiEndpoints.feedback, data: {'type': _type, 'value': _ctrl.text.trim()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ सुझाव भेजा गया। धन्यवाद!')));
        _ctrl.clear();
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('भेजने में समस्या')));
    }
    setState(() => _loading = false);
  }

  Widget _chip(String label, String value) => ChoiceChip(
    label: Text(label),
    selected: _type == value,
    onSelected: (_) => setState(() => _type = value),
    selectedColor: AppColors.saffron,
    labelStyle: TextStyle(
      color: _type == value ? Colors.white : AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
  );
}

