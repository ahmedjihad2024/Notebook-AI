import 'package:notebook_ai/core/services/storage_services/secure_storage_service.dart';
import 'package:notebook_ai/core/services/storage_services/shared_prefrences_service.dart';
import 'package:flutter/material.dart';

// dart format off
abstract class StorageServiceBase {
  final SecureStorageService _secureStorageService;
  final SharedPrefsService   _sharedPrefsService;
  StorageServiceBase(this._secureStorageService, this._sharedPrefsService);
}

class StorageService extends StorageServiceBase {
  StorageService(super._secureStorageService, super._sharedPrefsService);

  // Token
  Future<void> setToken(String token)                        async => await _secureStorageService.setToken(token);
  Future<String?> getToken()                                 async => await _secureStorageService.token;
  Future<void> deleteToken()                                 async => await _secureStorageService.deleteToken();

  // Role (server-assigned)
  Future<void> setRole(String role)                          async => await _secureStorageService.setRole(role);
  Future<String?> getRole()                                  async => await _secureStorageService.role;
  Future<void> deleteRole()                                  async => await _secureStorageService.deleteRole();

  // User Data
  Future<void> setSecureMap(Map<String, dynamic> data)       async => await _secureStorageService.setSecureMap(data);
  Future<Map<String, dynamic>?> secureMap()                  async => await _secureStorageService.secureMap;
  Future<void> deleteSecureMap()                             async => await _secureStorageService.deleteSecureMap();

  // Language
  Future<void> setLanguage(Locale code)                      async => await _sharedPrefsService.setLanguage(code);
  Locale? get language                                             =>       _sharedPrefsService.language;

  // Theme Mode
  Future<void> setThemeMode(ThemeMode mode)                  async => await _sharedPrefsService.setThemeMode(mode);
  ThemeMode get themeMode                                          =>       _sharedPrefsService.themeMode;

  // Map
  Future<void> setMap(String key, Map<String, dynamic> data) async => await _sharedPrefsService.setMap(key, data);
  Map<String, dynamic>? getMap(String key)                         =>       _sharedPrefsService.getMap(key);
  Future<void> deleteMap(String key)                         async => await _sharedPrefsService.deleteMap(key);

  // Location
  Future<void> saveLocationData({
    required double latitude,
    required double longitude,
    required String address,
  })                                                         async => await _sharedPrefsService.saveLocationData(
    latitude: latitude,
    longitude: longitude,
    address: address,
  );
  
  Future<({double? latitude, double? longitude, String? address})>
    getLocationData()                                        async => await _sharedPrefsService.getLocationData();
  
  bool get isLocationSelected                                      =>       _sharedPrefsService.isLocationSelected;
  bool get shouldShowLocationDialog                                =>       _sharedPrefsService.shouldShowLocationDialog;
  int get locationDismissedCount                                   =>       _sharedPrefsService.locationDismissedCount;
  Future<void> incrementLocationDismissedCount()             async => await _sharedPrefsService.incrementLocationDismissedCount();
  Future<void> resetLocationDismissedCount()                 async => await _sharedPrefsService.resetLocationDismissedCount();
  
  Future<bool> get isUserRegistered                          async => await _secureStorageService.isUserRegistered();
  
  Future<void> setSkippedOnBoarding()                        async => await _sharedPrefsService.setSkippedOnBoarding();
  
  
  bool get isSkippedOnBoarding                                     =>       _sharedPrefsService.isSkippedOnBoarding;
  
  Future<void> deleteSkippedOnBoarding()                     async => await _sharedPrefsService.deleteSkippedOnBoarding();

  // Clear
  Future<void> clearAll()                                    async => {
    await Future.wait({
      _secureStorageService.clearAll(), 
      _sharedPrefsService.clearAll()
    })
  };
}
