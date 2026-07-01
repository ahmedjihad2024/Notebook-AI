import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:for_u/app/config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

// dart format off
abstract class SharedPrefsServiceBase {
  final SharedPreferences _prefs;
  SharedPrefsServiceBase(this._prefs);

  static const _themeKey    = 'theme_mode';
  static const _languageKey = 'language_code';

  // String (e.g., Language)
  Future<void> setLanguage(Locale code)                      async => await _prefs.setString(_languageKey, code.toString());
  Locale? get language {
    final code = _prefs.getString(_languageKey);
    if (code == null) return null;
    if (code.contains('_')) {
      final parts = code.split('_');
      return Locale(parts[0], parts[1]); // e.g., Locale('en', 'US')
    } else {
      return Locale(code); // e.g., Locale('en')
    }
  }

  // Int (e.g., Theme Mode: 0 for light, 1 for dark, 2 for system)
  Future<void> setThemeMode(ThemeMode mode)                  async => await _prefs.setInt(_themeKey, mode.index);
  ThemeMode get themeMode                                          =>       ThemeMode.values[_prefs.getInt(_themeKey) ?? 0];

  // Generic Map (JSON)
  Future<void> setMap(String key, Map<String, dynamic> data) async => await _prefs.setString(key, jsonEncode(data));
  Map<String, dynamic>? getMap(String key) {
    final data = _prefs.getString(key);
    return data != null ? jsonDecode(data) as Map<String, dynamic> : null;
  }

  Future<void> deleteMap(String key)                         async => await _prefs.remove(key);

  // Helper Clear Methods
  Future<void> remove(String key)                            async => await _prefs.remove(key);
  Future<void> clearAll()                                    async => await _prefs.clear();
}

class SharedPrefsService extends SharedPrefsServiceBase {
  SharedPrefsService(super.prefs);
  
  static const _userLatitudeKey      = 'user-latitude';
  static const _userLongitudeKey     = 'user-longitude';
  static const _userAddressKey       = 'user-address';
  static const _skippedOnBoardingKey = 'skipped-on-boarding';
  static const _locationDismissedKey = 'location-dismissed-counter';

  Future<void> saveLocationData({
    required double latitude,
    required double longitude,
    required String address,
  })                                                         async {
    await _prefs.setDouble(_userLatitudeKey, latitude);
    await _prefs.setDouble(_userLongitudeKey, longitude);
    await _prefs.setString(_userAddressKey, address);
  }

  int get locationDismissedCount                                   =>       _prefs.getInt(_locationDismissedKey) ?? 0;
  bool get shouldShowLocationDialog                                =>       locationDismissedCount < Constants.locationDialogShowCountLimit;
  Future<void> incrementLocationDismissedCount()             async => await _prefs.setInt(_locationDismissedKey, locationDismissedCount + 1);
  Future<void> resetLocationDismissedCount()                 async => await _prefs.setInt(_locationDismissedKey, 0);

  Future<({double? latitude, double? longitude, String? address})>
    getLocationData()                                        async {
    final latitude = _prefs.getDouble(_userLatitudeKey);
    final longitude = _prefs.getDouble(_userLongitudeKey);
    final address = _prefs.getString(_userAddressKey);

    return (latitude: latitude, longitude: longitude, address: address);
  }

  bool get isLocationSelected {
    final latitude = _prefs.getDouble(_userLatitudeKey);
    final longitude = _prefs.getDouble(_userLongitudeKey);
    final address = _prefs.getString(_userAddressKey);

    // Return true if all location data is available
    return latitude != null &&
        longitude != null &&
        address != null &&
        address.isNotEmpty;
  }

  Future<void> setSkippedOnBoarding()                        async => await _prefs.setBool(_skippedOnBoardingKey, true);
  bool get isSkippedOnBoarding                                     =>       _prefs.getBool(_skippedOnBoardingKey) ?? false;
  Future<void> deleteSkippedOnBoarding()                     async => await _prefs.remove(_skippedOnBoardingKey);
}
