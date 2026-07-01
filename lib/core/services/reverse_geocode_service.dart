import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';

class ReverseGeocodeResult {
  final String? street;
  final String? buildingNumber;
  final String? area;
  final String? displayAddress;

  const ReverseGeocodeResult({
    this.street,
    this.buildingNumber,
    this.area,
    this.displayAddress,
  });
}

class ReverseGeocodeService {
  ReverseGeocodeService._();
  static final ReverseGeocodeService instance = ReverseGeocodeService._();
  static final RegExp _hasDigit = RegExp(r'\d');

  Future<ReverseGeocodeResult?> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;

      final placemark = placemarks.first;
      final street = _firstText([placemark.thoroughfare, placemark.street]);
      final buildingCandidate = _firstText([
        placemark.subThoroughfare,
        placemark.name,
      ]);
      final building = _buildingNumber(buildingCandidate);
      final area = _firstText([
        placemark.subLocality,
        placemark.locality,
        placemark.subAdministrativeArea,
        placemark.administrativeArea,
      ]);

      return ReverseGeocodeResult(
        street: street,
        buildingNumber: building,
        area: area,
        displayAddress: _displayAddress(street, building, area),
      );
    } on PlatformException {
      return null;
    }
  }

  String? _firstText(List<String?> parts) {
    for (final part in parts) {
      final trimmed = part?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  String? _buildingNumber(String? candidate) {
    if (candidate == null || !_hasDigit.hasMatch(candidate)) return null;
    return candidate;
  }

  String? _displayAddress(String? street, String? building, String? area) {
    final parts = [area, street, building]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return null;
    return parts.join('، ');
  }
}
