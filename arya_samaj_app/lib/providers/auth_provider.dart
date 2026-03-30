import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiClientProvider));
});

class AuthState {
  final bool isLoading;
  final String? error;
  final String? token;
  final bool profileComplete;
  AuthState({this.isLoading = false, this.error, this.token, this.profileComplete = false});
  AuthState copyWith({bool? isLoading, String? error, String? token, bool? profileComplete}) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        token: token ?? this.token,
        profileComplete: profileComplete ?? this.profileComplete,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _api;
  AuthNotifier(this._api) : super(AuthState()) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final profileComplete = prefs.getBool('profile_complete') ?? false;
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(token: token, profileComplete: profileComplete);
    }
  }

  Future<bool> sendOtp(String mobile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.post(ApiEndpoints.sendOtp, data: {'mobile': mobile});
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'OTP भेजने में समस्या');
      return false;
    }
  }

  Future<bool> verifyOtp(String mobile, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.post(ApiEndpoints.verifyOtp, data: {'mobile': mobile, 'otp': otp});
      final token = res.data['data']['token'] as String;
      final profileComplete = res.data['data']['user']['profile_complete'] == true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_mobile', mobile);
      await prefs.setBool('profile_complete', profileComplete);
      state = state.copyWith(isLoading: false, token: token, profileComplete: profileComplete);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'OTP गलत है या समय सीमा समाप्त');
      return false;
    }
  }

  Future<void> markProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profile_complete', true);
    state = state.copyWith(profileComplete: true);
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiEndpoints.logout);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_mobile');
    await prefs.remove('profile_complete');
    state = AuthState();
  }
}

