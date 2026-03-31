import 'member_category_model.dart';

class UserImageModel {
  final int id;
  final String url;

  const UserImageModel({required this.id, required this.url});

  factory UserImageModel.fromJson(Map<String, dynamic> j) =>
      UserImageModel(id: j['id'] as int, url: j['url'] as String);
}

class MemberUserModel {
  final int id;
  final String name;
  final String? username;
  final String? mobile;
  final String? gender;
  final String? dob;
  final String? country;
  final String? state;
  final String? district;
  final String? tehsil;
  final String? village;
  final String? postOffice;
  final String? pincode;
  final String? about;
  final String? orgType;
  final String? orgName;
  final String? profileImage;
  final bool isVerified;
  final int? profileViews;
  final List<MemberCategoryModel> categories;
  final List<UserImageModel> images;

  const MemberUserModel({
    required this.id,
    required this.name,
    this.username,
    this.mobile,
    this.gender,
    this.dob,
    this.country,
    this.state,
    this.district,
    this.tehsil,
    this.village,
    this.postOffice,
    this.pincode,
    this.about,
    this.orgType,
    this.orgName,
    this.profileImage,
    this.isVerified = false,
    this.profileViews,
    this.categories = const [],
    this.images = const [],
  });

  factory MemberUserModel.fromJson(Map<String, dynamic> j) => MemberUserModel(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        username: j['username'] as String?,
        mobile: j['mobile'] as String?,
        gender: j['gender'] as String?,
        dob: j['dob'] as String?,
        country: j['country'] as String?,
        state: j['state'] as String?,
        district: j['district'] as String?,
        tehsil: j['tehsil'] as String?,
        village: j['village'] as String?,
        postOffice: j['post_office'] as String?,
        pincode: j['pincode'] as String?,
        about: j['about'] as String?,
        orgType: j['org_type'] as String?,
        orgName: j['org_name'] as String?,
        profileImage: j['profile_image'] as String?,
        isVerified: j['is_verified'] == true,
        profileViews: j['profile_views'] as int?,
        categories: (j['categories'] as List? ?? [])
            .map((c) => MemberCategoryModel.fromJson(c as Map<String, dynamic>))
            .toList(),
        images: (j['images'] as List? ?? [])
            .map((i) => UserImageModel.fromJson(i as Map<String, dynamic>))
            .toList(),
      );
}
