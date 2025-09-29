import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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

  // New method to get address from coordinates
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Build address string from available components
        String address = '';

        // Add street number and name
        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }

        // Add subLocality (area/neighborhood)
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.subLocality!;
        }

        // Add locality (city/town)
        if (place.locality != null && place.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.locality!;
        }

        // Add administrative area (state/province)
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }

        // Add country
        if (place.country != null && place.country!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.country!;
        }

        // If no components found, create a basic address
        if (address.isEmpty) {
          address = '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
        }

        return address;
      } else {
        return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
      }
    } catch (e) {
      print('Error getting address: $e');
      return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    }
  }

  // Method to get current location with address
  Future<Map<String, dynamic>> getCurrentLocationWithAddress({bool forceRefresh = false}) async {
    try {
      Position position = await getCurrentLocation(forceRefresh: forceRefresh);
      String address = await getAddressFromCoordinates(position.latitude, position.longitude);

      return {
        'position': position,
        'address': address,
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      rethrow;
    }
  }


  // Method to get a short address (for display in app bar)
  Future<String> getShortAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String shortAddress = '';

        // Priority: subLocality -> locality -> administrativeArea
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          shortAddress = place.subLocality!;
        } else if (place.locality != null && place.locality!.isNotEmpty) {
          shortAddress = place.locality!;
        } else if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          shortAddress = place.administrativeArea!;
        }

        return shortAddress.isNotEmpty ? shortAddress : 'Current Location';
      }
      return 'Current Location';
    } catch (e) {
      return 'Current Location';
    }
  }
}