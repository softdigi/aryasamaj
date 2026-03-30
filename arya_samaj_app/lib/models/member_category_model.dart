class MemberCategoryModel {
  final int id;
  final String name;
  final String slug;
  final String group; // 'role' | 'org'

  const MemberCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.group,
  });

  factory MemberCategoryModel.fromJson(Map<String, dynamic> j) =>
      MemberCategoryModel(
        id:    j['id'] as int,
        name:  j['name'] as String,
        slug:  j['slug'] as String? ?? '',
        group: j['group'] as String? ?? 'role',
      );
}
