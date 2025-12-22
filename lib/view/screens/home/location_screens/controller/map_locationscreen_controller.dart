// map_location_controller.dart
import 'dart:async';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/newlocation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:provider/provider.dart';

class MapLocationController {
  final BuildContext context;

  // Controllers
  final Completer<GoogleMapController> mapController = Completer();
  final TextEditingController addressController = TextEditingController();
  final FocusNode addressFocusNode = FocusNode();

  // State management callback
  final Function(VoidCallback) setState;

  // State variables
  LatLng? selectedLocation;
  Set<Marker> markers = {};
  String selectedAddress = '';
  bool isLoadingAddress = false;
  bool isLoadingCurrentLocation = false;

  // Map themes
  String? darkMapTheme;
  String? lightMapTheme;

  // Constants
  late final String googlePlacesApiKey;
  static const CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(22.3569, 91.7832), // Chittagong coordinates
    zoom: 14.4746,
  );

  MapLocationController(this.context, this.setState) {
    googlePlacesApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }

  // ============ INITIALIZATION (replaces initState) ============

  Future<void> initialize() async {
    await _loadMapThemes();
    await getCurrentLocation();
  }

  Future<void> _loadMapThemes() async {
    try {
      darkMapTheme = await rootBundle.loadString('assets/map_theme/nighttheme.json');
      lightMapTheme = await rootBundle.loadString('assets/map_theme/standaredtheme.json');
    } catch (e) {
      debugPrint('Error loading map themes: $e');
    }
  }

  // ============ MAP THEME HANDLING ============

  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  String? get currentMapTheme => isDarkMode ? darkMapTheme : lightMapTheme;

  Future<void> setMapStyle() async {
    if (mapController.isCompleted) {
      final GoogleMapController controller = await mapController.future;
      final String? theme = currentMapTheme;
      if (theme != null) {
        await controller.setMapStyle(theme);
      }
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
    setMapStyle();
  }

  // ============ LOCATION HANDLING ============

  Future<void> getCurrentLocation() async {
    setState(() {
      isLoadingCurrentLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          isLoadingCurrentLocation = false;
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
            isLoadingCurrentLocation = false;
          });
          await Geolocator.openAppSettings();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          isLoadingCurrentLocation = false;
        });
        await Geolocator.openAppSettings();
        return;
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition();
      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      await updateSelectedLocation(currentLocation);

      // Move camera to current location
      final GoogleMapController controller = await mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation, zoom: 16.0),
        ),
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting current location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoadingCurrentLocation = false;
      });
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

  // ============ UPDATE SELECTED LOCATION ============

  Future<void> updateSelectedLocation(LatLng location) async {
    setState(() {
      selectedLocation = location;
      isLoadingAddress = true;
      markers = {
        Marker(
          markerId: const MarkerId('selected-location'),
          position: location,
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            updateSelectedLocation(newPosition);
          },
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet: 'Tap to get address',
          ),
        ),
      };
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.street ?? ''}, ${place.locality ?? ''}, '
            '${place.administrativeArea ?? ''}, ${place.country ?? ''}';

        setState(() {
          selectedAddress = address.replaceAll(RegExp(r'^, |, $'), '');
          addressController.text = selectedAddress;
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      setState(() {
        selectedAddress = 'Address not found';
        addressController.text = selectedAddress;
      });
    } finally {
      setState(() {
        isLoadingAddress = false;
      });
    }
  }

  // ============ HANDLE MAP TAP ============

  void onMapTap(LatLng location) {
    updateSelectedLocation(location);
  }

  // ============ PLACE SELECTION ============

  Future<void> onPlaceSelected(Prediction prediction) async {
    try {
      List<Location> locations = await locationFromAddress(prediction.description!);
      if (locations.isNotEmpty) {
        LatLng selectedLoc = LatLng(locations.first.latitude, locations.first.longitude);

        await updateSelectedLocation(selectedLoc);

        // Move camera to selected location
        final GoogleMapController controller = await mapController.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: selectedLoc, zoom: 16.0),
          ),
        );

        // Unfocus the text field
        addressFocusNode.unfocus();
      }
    } catch (e) {
      debugPrint('Error selecting place: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting place: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============ LOCATION CONFIRMATION ============

  Future<void> confirmLocation() async {
    if (selectedLocation != null && selectedAddress.isNotEmpty) {
      try {
        final locationData = {
          "geoLocation": {
            "type": "Point",
            "coordinates": [selectedLocation!.longitude, selectedLocation!.latitude],
          },
          "fullAddress": selectedAddress,
          "type": "DELIVERY_ADDRESS",
        };

        final addLocationViewModel = Provider.of<AddLocationViewModel>(
          context,
          listen: false,
        );
        await addLocationViewModel.addLocationPostApi(context, locationData,true);
      } catch (e) {
        debugPrint('Error saving location: $e');
        Utils.flushBarErrorMessage('Failed to save location', context);
      }
    } else {
      Utils.flushBarErrorMessage('Please select a location', context);
    }
  }

  // ============ CLEAR SELECTION ============

  void clearSelection() {
    addressController.clear();
    setState(() {
      selectedLocation = null;
      markers.clear();
      selectedAddress = '';
    });
  }

  // ============ CLEANUP (replaces dispose) ============

  void dispose() {
    addressController.dispose();
    addressFocusNode.dispose();
  }
}