import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService _storageService;

  AuthService(this._storageService);

  /// Register new user
  Future<bool> register(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storageService.saveToken(data['token']);
        await _storageService.saveUserData(
          data['user_id'],
          data['email'],
          data['name'],
        );
        return true;
      } else {
        print('Registration failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  /// Login existing user
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storageService.saveToken(data['token']);
        await _storageService.saveUserData(
          data['user_id'],
          data['email'],
          data['name'] ?? '',
        );
        return true;
      } else {
        print('Login failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _storageService.logout();
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _storageService.isLoggedIn();
  }

  /// Get current user data
  User? getCurrentUser() {
    final userId = _storageService.getUserId();
    final email = _storageService.getEmail();
    final name = _storageService.getName();

    if (userId != null && email != null) {
      return User(userId: userId, email: email, name: name ?? '');
    }
    return null;
  }
}
