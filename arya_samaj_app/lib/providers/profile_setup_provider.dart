import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/member_category_model.dart';
import '../models/member_user_model.dart';

class ProfileSetupState {
  // Step tracking
  final int currentStep; // 1-5
  final bool isLoading;
  final String? error;
  final bool done;

  // Step 1: Basic info
  final String name;
  final String username;
  final String gender; // male/female/other
  final String dob;
  final File? profileImageFile;
  final String? profileImageUrl;

  // Step 2: Address
  final String country;
  final String state;
  final String district;
  final String tehsil;
  final String village;
  final String postOffice;
  final String pincode;

  // Step 3: Categories
  final List<int> selectedCategoryIds;
  final String orgType;
  final String orgName;

  // Step 4: About
  final String about;

  // Step 5: Images
  final List<UserImageModel> uploadedImages;

  const ProfileSetupState({
    this.currentStep = 1,
    this.isLoading = false,
    this.error,
    this.done = false,
    this.name = '',
    this.username = '',
    this.gender = 'male',
    this.dob = '',
    this.profileImageFile,
    this.profileImageUrl,
    this.country = 'India',
    this.state = '',
    this.district = '',
    this.tehsil = '',
    this.village = '',
    this.postOffice = '',
    this.pincode = '',
    this.selectedCategoryIds = const [],
    this.orgType = '',
    this.orgName = '',
    this.about = '',
    this.uploadedImages = const [],
  });

  ProfileSetupState copyWith({
    int? currentStep,
    bool? isLoading,
    String? error,
    bool? done,
    String? name,
    String? username,
    String? gender,
    String? dob,
    File? profileImageFile,
    String? profileImageUrl,
    String? country,
    String? state,
    String? district,
    String? tehsil,
    String? village,
    String? postOffice,
    String? pincode,
    List<int>? selectedCategoryIds,
    String? orgType,
    String? orgName,
    String? about,
    List<UserImageModel>? uploadedImages,
  }) =>
      ProfileSetupState(
        currentStep: currentStep ?? this.currentStep,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        done: done ?? this.done,
        name: name ?? this.name,
        username: username ?? this.username,
        gender: gender ?? this.gender,
        dob: dob ?? this.dob,
        profileImageFile: profileImageFile ?? this.profileImageFile,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        country: country ?? this.country,
        state: state ?? this.state,
        district: district ?? this.district,
        tehsil: tehsil ?? this.tehsil,
        village: village ?? this.village,
        postOffice: postOffice ?? this.postOffice,
        pincode: pincode ?? this.pincode,
        selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
        orgType: orgType ?? this.orgType,
        orgName: orgName ?? this.orgName,
        about: about ?? this.about,
        uploadedImages: uploadedImages ?? this.uploadedImages,
      );
}

final profileSetupProvider = StateNotifierProvider<ProfileSetupNotifier, ProfileSetupState>((ref) {
  return ProfileSetupNotifier(ref.read(apiClientProvider));
});

class ProfileSetupNotifier extends StateNotifier<ProfileSetupState> {
  final ApiClient _api;
  ProfileSetupNotifier(this._api) : super(const ProfileSetupState());

  void update(ProfileSetupState Function(ProfileSetupState) updater) {
    state = updater(state);
  }

  // Submit Step 1+2 (basic info + address + optional profile photo)
  Future<bool> submitBasicAndAddress() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final formData = FormData.fromMap({
        'name': state.name,
        'username': state.username,
        'gender': state.gender,
        'dob': state.dob,
        'country': state.country,
        'state': state.state,
        'district': state.district,
        'tehsil': state.tehsil,
        'village': state.village,
        'post_office': state.postOffice,
        'pincode': state.pincode,
        if (state.profileImageFile != null)
          'profile_image': await MultipartFile.fromFile(
            state.profileImageFile!.path,
            filename: 'profile.jpg',
          ),
      });
      final res = await _api.postForm(ApiEndpoints.saveProfile, formData: formData);
      final url = res.data['data']['profile_image'] as String?;
      state = state.copyWith(isLoading: false, profileImageUrl: url, currentStep: 3);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'प्रोफाइल सेव नहीं हुई');
      return false;
    }
  }

  // Submit Step 3 (categories + org)
  Future<bool> submitCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.post(ApiEndpoints.saveCategories, data: {
        'category_ids': state.selectedCategoryIds,
        'org_type': state.orgType,
        'org_name': state.orgName,
      });
      state = state.copyWith(isLoading: false, currentStep: 4);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'श्रेणी सेव नहीं हुई');
      return false;
    }
  }

  // Submit Step 4 (about)
  Future<bool> submitAbout() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.post(ApiEndpoints.saveAbout, data: {'about': state.about});
      state = state.copyWith(isLoading: false, currentStep: 5);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'परिचय सेव नहीं हुआ');
      return false;
    }
  }

  // Submit Step 5 (images)
  Future<bool> submitImages(List<File> files) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final multiparts = await Future.wait(files.asMap().entries.map((e) =>
          MultipartFile.fromFile(e.value.path, filename: 'image_${e.key}.jpg')));
      final formData = FormData.fromMap({
        'images': multiparts,
      });
      final res = await _api.postForm(ApiEndpoints.uploadImages, formData: formData);
      final imgs = (res.data['data']['images'] as List)
          .map((i) => UserImageModel.fromJson(i as Map<String, dynamic>))
          .toList();
      state = state.copyWith(isLoading: false, uploadedImages: imgs, done: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'फोटो अपलोड नहीं हुई');
      return false;
    }
  }

  Future<bool> deleteImage(int imageId) async {
    try {
      await _api.delete('/images/$imageId');
      state = state.copyWith(
        uploadedImages: state.uploadedImages.where((i) => i.id != imageId).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  void goToStep(int step) => state = state.copyWith(currentStep: step);
}
