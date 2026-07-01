import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:for_u/app/di/dependency_injection.dart';
import 'package:for_u/app/utils/snackbar_helper.dart';
import 'package:for_u/presentation/res/translations_manager.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Future<Position?> determinePosition() async {
    LocationPermission permission;
    try {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        DI().snackBarHelper.showMessage(
          Translation.location_permissions_permanently_denied.tr,
          ErrorMessage.snackBar,
          isError: true,
          snackbarSeconds: 6,
        );
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 100,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  Future<String?> getAddressFromLatLng(Position latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      Placemark placemark = placemarks.length > 1
          ? placemarks[1]
          : placemarks.first;

      String cityName =
          placemark.locality ??
          placemark.subAdministrativeArea ??
          placemark.administrativeArea ??
          placemark.thoroughfare ??
          placemark.name ??
          Translation.unknown_location.tr;

      return cityName;
    } catch (e) {
      return null;
    }
  }
}
