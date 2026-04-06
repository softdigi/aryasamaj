class CategoryModel {
  final int id;
  final String name;
  final String? icon;
  final String? type;
  final bool hasChild;

  CategoryModel({
    required this.id, required this.name,
    this.icon, this.type, required this.hasChild,
  });

  factory CategoryModel.fromJson(Map j) => CategoryModel(
    id: j['id'], name: j['name'], icon: j['icon'],
    type: j['type'], hasChild: j['has_child'] == true,
  );
}
