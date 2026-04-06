class FeatureModel {
  final int id;
  final String name;
  final String? nameHindi;
  final String? icon;
  final String route;
  final String section;

  FeatureModel({
    required this.id, required this.name, this.nameHindi,
    this.icon, required this.route, required this.section,
  });

  factory FeatureModel.fromJson(Map j) => FeatureModel(
    id: j['id'], name: j['name'], nameHindi: j['name_hindi'],
    icon: j['icon'], route: j['route'], section: j['section'] ?? 'main',
  );
}
