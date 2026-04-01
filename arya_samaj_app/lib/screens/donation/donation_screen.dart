import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../models/donation_model.dart';

final donationProvider = FutureProvider<List<DonationModel>>((ref) async {
  final api = ref.read(apiClientProvider);
  final res = await api.get(ApiEndpoints.donation);
  return (res.data['data'] as List).map((e) => DonationModel.fromJson(e)).toList();
});

class DonationScreen extends ConsumerStatefulWidget {
  const DonationScreen({super.key});

  @override
  ConsumerState<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends ConsumerState<DonationScreen> {
  late final Razorpay _razorpay;
  final _amountCtrl = TextEditingController();
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _onSuccess(PaymentSuccessResponse response) async {
    final amountPaise = (double.tryParse(_amountCtrl.text) ?? 0) * 100;
    try {
      await ref.read(apiClientProvider).post(ApiEndpoints.donationPay, data: {
        'razorpay_payment_id': response.paymentId,
        'razorpay_order_id': response.orderId,
        'amount': amountPaise / 100,
        'currency': 'INR',
        'notes': 'Donation via app',
      });
    } catch (_) {}
    if (mounted) {
      setState(() => _paying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🙏 धन्यवाद! आपका दान सफलतापूर्वक प्राप्त हुआ।'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _onError(PaymentFailureResponse response) {
    setState(() => _paying = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('भुगतान विफल: ${response.message ?? 'कृपया पुनः प्रयास करें'}'),
            backgroundColor: AppColors.error),
      );
    }
  }

  void _onWallet(ExternalWalletResponse response) {
    setState(() => _paying = false);
  }

  void _openRazorpay() {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('न्यूनतम ₹1 दर्ज करें')));
      return;
    }
    setState(() => _paying = true);
    final options = {
      'key': 'rzp_live_REPLACE_WITH_YOUR_KEY', // Replace with actual key
      'amount': (amount * 100).toInt(),
      'currency': 'INR',
      'name': 'Arya Samaj',
      'description': 'Donation',
      'prefill': {'contact': '', 'email': ''},
      'theme': {'color': '#FF6B00'},
    };
    _razorpay.open(options);
  }

  @override
  Widget build(BuildContext context) {
    final donAsync = ref.watch(donationProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('सहयोग करें')),
      body: donAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
        error: (e, _) => const Center(child: Text('लोड नहीं हो सका')),
        data: (donations) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Razorpay Payment Card ──────────────────────────────────
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B00), Color(0xFFCC5500)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: AppColors.saffron.withOpacity(.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('ऑनलाइन दान करें', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Razorpay द्वारा सुरक्षित भुगतान', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: 'राशि ₹',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(.7)),
                        prefixIcon: const Icon(Icons.currency_rupee, color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(.2),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _paying ? null : _openRazorpay,
                    icon: _paying
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.saffron, strokeWidth: 2))
                        : const Icon(Icons.payment),
                    label: const Text('दान करें'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.saffron,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [100, 251, 501, 1001, 2101].map((amt) =>
                    GestureDetector(
                      onTap: () => _amountCtrl.text = amt.toString(),
                      child: Chip(
                        label: Text('₹$amt', style: const TextStyle(color: AppColors.saffron, fontWeight: FontWeight.w700)),
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                    )
                  ).toList(),
                ),
              ]),
            ),

            const Text('All accepted', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _payApp('PhonePe', Colors.purple),
              _payApp('Paytm', Colors.blue),
              _payApp('GPay', Colors.green),
              _payApp('YONO SBI', Colors.purple.shade900),
            ]),
            const SizedBox(height: 24),
            ...donations.map((d) => _buildCard(context, d)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFE0B2), Color(0xFFFFF8E1)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(children: [
                Text('आपका सहयोग हमें दोगुनी उत्साह से कार्य करने के लिए प्रोत्साहित करता है।',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 12),
                Icon(Icons.volunteer_activism, size: 48, color: AppColors.saffron),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _payApp(String name, Color color) => Column(children: [
    Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.3)),
      ),
      child: Center(child: Text(name[0], style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color))),
    ),
    const SizedBox(height: 4),
    Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
  ]);

  Widget _buildCard(BuildContext context, DonationModel d) {
    if (d.type == 'qr' && d.imageUrl != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(children: [
          const Text('QR Code से भेजें', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          CachedNetworkImage(imageUrl: d.imageUrl!, width: 220, height: 220),
        ]),
      );
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (d.accountName != null) ...[
          const Text('Account Name', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(d.accountName!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.navy)),
          const SizedBox(height: 8),
        ],
        if (d.accountNumber != null) _detailRow(context, 'A/c', d.accountNumber!),
        if (d.ifscCode != null) _detailRow(context, 'IFSC', d.ifscCode!),
        if (d.upiId != null) _detailRow(context, 'UPI', d.upiId!),
      ]),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Text('$label - ', style: const TextStyle(fontWeight: FontWeight.w700)),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
      GestureDetector(
        onTap: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label copied!')));
        },
        child: const Icon(Icons.copy, size: 18, color: AppColors.navy),
      ),
    ]),
  );
}
    return Scaffold(
      appBar: AppBar(title: const Text('सहयोग करें')),
      body: donAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
        error: (e, _) => const Center(child: Text('लोड नहीं हो सका')),
        data: (donations) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('All accepted', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _payApp('PhonePe', Colors.purple),
              _payApp('Paytm', Colors.blue),
              _payApp('GPay', Colors.green),
              _payApp('YONO SBI', Colors.purple.shade900),
            ]),
            const SizedBox(height: 24),
            ...donations.map((d) => _buildCard(context, d)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFE0B2), Color(0xFFFFF8E1)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(children: [
                Text('आपका सहयोग हमें दोगुनी उत्साह से कार्य करने के लिए प्रोत्साहित करता है।',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 12),
                Icon(Icons.volunteer_activism, size: 48, color: AppColors.saffron),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _payApp(String name, Color color) => Column(children: [
    Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.3)),
      ),
      child: Center(child: Text(name[0], style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color))),
    ),
    const SizedBox(height: 4),
    Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
  ]);

  Widget _buildCard(BuildContext context, DonationModel d) {
    if (d.type == 'qr' && d.imageUrl != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(children: [
          const Text('QR Code से भेजें', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          CachedNetworkImage(imageUrl: d.imageUrl!, width: 220, height: 220),
        ]),
      );
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (d.accountName != null) ...[
          const Text('Account Name', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(d.accountName!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.navy)),
          const SizedBox(height: 8),
        ],
        if (d.accountNumber != null) _detailRow(context, 'A/c', d.accountNumber!),
        if (d.ifscCode != null) _detailRow(context, 'IFSC', d.ifscCode!),
        if (d.upiId != null) _detailRow(context, 'UPI', d.upiId!),
      ]),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Text('$label - ', style: const TextStyle(fontWeight: FontWeight.w700)),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
      GestureDetector(
        onTap: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label copied!')));
        },
        child: const Icon(Icons.copy, size: 18, color: AppColors.navy),
      ),
    ]),
  );
}

