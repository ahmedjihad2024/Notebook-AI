import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Save sensitive data using [flutter_secure_storage] library
// dart format off
abstract class SecureStorageServiceBase {

  final FlutterSecureStorage _storage;
  static const               _tokenKey    = 'access-token';
  static const               _roleKey     = 'user-role';
  static const               _mapDataKey = 'user-data';
  String?                     _cachedToken;
  String?                     _cachedRole;

  SecureStorageServiceBase(this._storage);

  /// [setToken] saving token using [flutter_secure_storage] library
  /// use [token] getter to get the token or null if there is no token saved
  /// use [deleteToken] to delete saved token
  Future<void> setToken(String token) async => {
    await _storage.write(key: _tokenKey, value: token),
    _cachedToken = token,
  };
  
  /// get saved token (cache-aside: first call hits storage, then in-memory)
  Future<String?> get token           async => _cachedToken ??= await _storage.read(key: _tokenKey);

  /// delete saved token
  Future<void> deleteToken()          async => {
    await _storage.delete(key: _tokenKey),
    _cachedToken = null,
  };

  /// check if there is token or not
  Future<bool> isUserRegistered()     async => (await _storage.read(key: _tokenKey)) != null;

  // Role (server-assigned at verify-otp; routing depends on it)
  Future<void> setRole(String role)   async => {
    await _storage.write(key: _roleKey, value: role),
    _cachedRole = role,
  };

  Future<String?> get role            async => _cachedRole ??= await _storage.read(key: _roleKey);

  Future<void> deleteRole()           async => {
    await _storage.delete(key: _roleKey),
    _cachedRole = null,
  };

  // User Data
  Future<void> setSecureMap(Map<String, dynamic> data) async => await _storage.write(key: _mapDataKey, value: jsonEncode(data));
  Future<Map<String, dynamic>?> get secureMap async {
    final data = await _storage.read(key: _mapDataKey);
    return data != null ? jsonDecode(data) : null;
  }
  Future<void> deleteSecureMap()      async => await _storage.delete(key: _mapDataKey);

  /// delete all saved data from secure storage
  Future<void> clearAll()             async => await _storage.deleteAll();
}

class SecureStorageService extends SecureStorageServiceBase {
  SecureStorageService([FlutterSecureStorage? storage])
    : super(
        storage ?? const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            ),
      );
}
