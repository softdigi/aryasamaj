import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../models/donation_model.dart';

final donationProvider = FutureProvider<List<DonationModel>>((ref) async {
  final api = ref.read(apiClientProvider);
  final res = await api.get(ApiEndpoints.donation);
  return (res.data['data'] as List).map((e) => DonationModel.fromJson(e)).toList();
});

class DonationScreen extends ConsumerWidget {
  const DonationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donAsync = ref.watch(donationProvider);
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

