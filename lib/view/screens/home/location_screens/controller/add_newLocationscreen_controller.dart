// add_newlocation_controller.dart
import 'package:dinmajur_customer/configs/services/location_services/location_getting.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/delete_location_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/get_locationlist_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/newlocation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddNewLocationController {
  final BuildContext context;
  final Function(VoidCallback) setState;

  // Services
  final LocationService _locationService = LocationService();

  // Location related variables
  Position? currentPosition;
  String? currentAddress;
  String? shortAddress;
  bool isLoadingLocation = false;
  String locationMessage = "Location not fetched yet.";

  // Selection related variables
  String? selectedLocationId;
  dynamic selectedLocationData;
  bool isUpdating = false;
  bool isDeleting = false;

  AddNewLocationController(this.context, this.setState);

  // ============ INITIALIZATION ============

  Future<void> initialize() async {
    await _fetchLocationList();
  }

  Future<void> _fetchLocationList() async {
    final locationViewModel = context.read<GetLocationListViewModel>();
    await locationViewModel.fetchLocationListApi();
  }

  // ============ LOCATION SELECTION ============

  void selectLocation(String locationId, dynamic locationData) {
    setState(() {
      if (selectedLocationId == locationId) {
        // Deselect if already selected
        selectedLocationId = null;
        selectedLocationData = null;
      } else {
        // Select new location
        selectedLocationId = locationId;
        selectedLocationData = locationData;
      }
    });
  }

  // ============ GET CURRENT LOCATION WITH PERMISSION HANDLING ============

  Future<void> getLocationWithAddress() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          isLoadingLocation = false;
          locationMessage = "Location services are disabled.";
        });
        _showLocationServicesDialog();
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            isLoadingLocation = false;
            locationMessage = "Location permission denied.";
          });
          await Geolocator.openAppSettings();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          isLoadingLocation = false;
          locationMessage = "Location permission permanently denied.";
        });
        await Geolocator.openAppSettings();
        return;
      }

      // Get location with address
      Map<String, dynamic> locationData =
      await _locationService.getCurrentLocationWithAddress();
      Position position = locationData['position'];
      String fullAddress = locationData['address'];
      String shortAddr = await _locationService.getShortAddress(
        position.latitude,
        position.longitude,
      );

      setState(() {
        currentPosition = position;
        currentAddress = fullAddress;
        shortAddress = shortAddr;
        locationMessage = "Latitude: ${position.latitude}, "
            "Longitude: ${position.longitude}";
        isLoadingLocation = false;
      });

      debugPrint('========== CURRENT LOCATION WITH ADDRESS ==========');
      debugPrint('Latitude: ${position.latitude}');
      debugPrint('Longitude: ${position.longitude}');
      debugPrint('Full Address: $fullAddress');
      debugPrint('Short Address: $shortAddr');
      debugPrint('==================================================');

      await _postLocationToApi(
        position.longitude,
        position.latitude,
        fullAddress,
      );
    } catch (e) {
      debugPrint('Error getting location with address: $e');
      setState(() {
        locationMessage = "Please enable location to use this app.";
        isLoadingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showLocationServicesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Location Services Disabled'),
          content: Text('Please enable location services to use this feature.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await Geolocator.openLocationSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  // ============ POST LOCATION TO API ============

  Future<void> _postLocationToApi(
      double longitude,
      double latitude,
      String fullAddress,
      ) async {
    try {
      final locationData = {
        "geoLocation": {
          "type": "Point",
          "coordinates": [longitude, latitude],
        },
        "fullAddress": fullAddress,
        "type": "DELIVERY_ADDRESS",
      };

      final addLocationViewModel = context.read<AddLocationViewModel>();
      await addLocationViewModel.addLocationPostApi(context, locationData,true);

      debugPrint('Location data to post: $locationData');
    } catch (e) {
      debugPrint('Error posting location to API: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save location: ${e.toString()}'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // ============ UPDATE SELECTED LOCATION ============

  Future<void> updateSelectedLocation() async {
    if (selectedLocationData == null) return;

    setState(() {
      isUpdating = true;
    });

    try {
      final coordinates = selectedLocationData.geoLocation?.coordinates ?? [];
      if (coordinates.length < 2) {
        throw Exception('Invalid coordinates');
      }

      final String locationId = selectedLocationData.id ?? '';
      if (locationId.isEmpty) {
        throw Exception('Location ID not found');
      }

      final locationData = {
        "default": true,
        "geoLocation": {
          "type": "Point",
          "coordinates": [coordinates[0], coordinates[1]],
        },
        "fullAddress": selectedLocationData.fullAddress ?? '',
        "type": selectedLocationData.type ?? "DELIVERY_ADDRESS",
      };

      final addLocationViewModel = context.read<AddLocationViewModel>();
      await addLocationViewModel.updateAddressPatchApi(
        context,
        locationData,
        locationId,
      );

      debugPrint('Updated location data: $locationData');
      debugPrint('Location ID: $locationId');
    } catch (e) {
      debugPrint('Error updating location: $e');

      setState(() {
        isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update location: ${e.toString()}'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // ============ DELETE LOCATION (placeholder) ============

  Future<void> deleteSelectedLocation() async {
    if (selectedLocationData == null) return;

    setState(() {
      isDeleting = true;
    });

    try {
      final String locationId = selectedLocationData.id ?? '';

      final deleteLocationViewModel = context.read<DeleteLocationViewModel>();
      await deleteLocationViewModel.deleteLocationDeleteApi(
        context,
        locationId,
      );
      setState(() {
        selectedLocationId = null;
        selectedLocationData = null;
        isDeleting = false;
      });

    } catch (e) {
      debugPrint('Error deleting location: $e');

      setState(() {
        isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete location: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // ============ NAVIGATION ============

  void navigateToMapScreen() {
    Navigator.pushNamed(context, RoutesName.mapLocationScreen);
  }

  void navigateBack() {
    Navigator.pop(context);
  }

  // ============ UTILITY METHODS ============

  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }

  // ============ CLEANUP ============

  void dispose() {
    // Clean up any resources if needed
  }
}