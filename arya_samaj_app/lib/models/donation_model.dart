class DonationModel {
  final int id;
  final String type;
  final String? accountName;
  final String? accountNumber;
  final String? ifscCode;
  final String? upiId;
  final String? imageUrl;

  DonationModel({
    required this.id, required this.type, this.accountName,
    this.accountNumber, this.ifscCode, this.upiId, this.imageUrl,
  });

  factory DonationModel.fromJson(Map j) => DonationModel(
    id: j['id'], type: j['type'], accountName: j['account_name'],
    accountNumber: j['account_number'], ifscCode: j['ifsc_code'],
    upiId: j['upi_id'], imageUrl: j['image_url'],
  );
}
