import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static const String _tokenKey = 'jwt_token';
  static const String _deviceIdKey = 'device_id';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'email';
  static const String _nameKey = 'name';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Token management
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  // Device ID
  Future<String> getDeviceId() async {
    String? deviceId = _prefs.getString(_deviceIdKey);
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await _prefs.setString(_deviceIdKey, deviceId);
    }
    return deviceId;
  }

  // User data
  Future<void> saveUserData(String userId, String email, String name) async {
    await _prefs.setString(_userIdKey, userId);
    await _prefs.setString(_emailKey, email);
    await _prefs.setString(_nameKey, name);
  }

  String? getUserId() => _prefs.getString(_userIdKey);
  String? getEmail() => _prefs.getString(_emailKey);
  String? getName() => _prefs.getString(_nameKey);

  Future<void> clearUserData() async {
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_nameKey);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return getToken() != null;
  }

  // Logout
  Future<void> logout() async {
    await clearToken();
    await clearUserData();
  }
}
