import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/services/notification_service.dart';

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
  static const _storage = FlutterSecureStorage();

  AuthNotifier(this._api) : super(AuthState()) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await _storage.read(key: 'auth_token');
    final profileComplete = (await _storage.read(key: 'profile_complete')) == 'true';
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
      await _storage.write(key: 'auth_token', value: token);
      await _storage.write(key: 'user_mobile', value: mobile);
      await _storage.write(key: 'profile_complete', value: profileComplete.toString());
      state = state.copyWith(isLoading: false, token: token, profileComplete: profileComplete);

      // Register FCM token with the backend
      _registerFcmToken();

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'OTP गलत है या समय सीमा समाप्त');
      return false;
    }
  }

  Future<void> _registerFcmToken() async {
    try {
      final fcmToken = await NotificationService.getToken();
      if (fcmToken != null) {
        await _api.post(ApiEndpoints.fcmToken, data: {'fcm_token': fcmToken});
      }
    } catch (_) {
      // Non-critical — silently ignore FCM registration failures
    }
  }

  Future<void> markProfileComplete() async {
    await _storage.write(key: 'profile_complete', value: 'true');
    state = state.copyWith(profileComplete: true);
  }

  Future<void> logout() async {
    // Clear FCM token on the server before logging out
    try {
      await _api.post(ApiEndpoints.fcmToken, data: {'fcm_token': null});
    } catch (_) {}
    try {
      await _api.post(ApiEndpoints.logout);
    } catch (_) {}
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_mobile');
    await _storage.delete(key: 'profile_complete');
    state = AuthState();
  }
}

