import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

const _secureStorage = FlutterSecureStorage();

// Provider for admin authentication status
final isAdminProvider = StateProvider<bool>((ref) => false);

// Provider for admin token
final adminTokenProvider = StateProvider<String?>((ref) => null);

// Admin authentication service
final adminAuthProvider = Provider<AdminAuthService>((ref) {
  return AdminAuthService(ref);
});

class AdminAuthService {
  final Ref _ref;
  static const String _tokenKey = 'admin_token';

  AdminAuthService(this._ref);

  Future<bool> login(String passcode) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        'http://localhost:8000/auth/admin/login',
        data: {'passcode': passcode},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final token = response.data['access_token'];
      if (token != null) {
        await _secureStorage.write(key: _tokenKey, value: token);
        _ref.read(adminTokenProvider.notifier).state = token;
        _ref.read(isAdminProvider.notifier).state = true;
        return true;
      }
      return false;
    } catch (e) {
      print('Admin login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    _ref.read(adminTokenProvider.notifier).state = null;
    _ref.read(isAdminProvider.notifier).state = false;
  }

  Future<void> checkStoredToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token != null) {
        // TODO: Optionally verify token validity with backend
        _ref.read(adminTokenProvider.notifier).state = token;
        _ref.read(isAdminProvider.notifier).state = true;
      }
    } catch (e) {
      print('Error checking stored token: $e');
    }
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }
}
