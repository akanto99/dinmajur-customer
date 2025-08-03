// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class LocationService {
//   Future<Position> checkPermissionAndGetLocation() async {
//     // Check if location services are enabled
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       await Geolocator.openLocationSettings();
//       throw Exception("Location services are disabled.");
//     }
//
//     // Check permission
//     LocationPermission permission = await Geolocator.checkPermission();
//
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//
//     if (permission == LocationPermission.denied) {
//       // User denied again — open settings
//       await openAppSettings();
//       throw Exception("Location permission denied.");
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       // Denied permanently — open settings
//       await openAppSettings();
//       throw Exception("Location permission permanently denied.");
//     }
//
//     // Permission granted
//     return await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//   }
// }
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Position? _cachedPosition;

  Future<Position> getCurrentLocation({bool forceRefresh = false}) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw Exception("Location permissions are denied.");
      }
    }

    if (_cachedPosition != null && !forceRefresh) {
      return _cachedPosition!;
    }

    _cachedPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return _cachedPosition!;
  }
}

