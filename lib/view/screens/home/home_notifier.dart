import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dinmajur_customer/configs/services/location_services/location_getting.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/newlocation_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_and_order_view_models/nearby_retailers_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/check_coverage_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';

class HomeNotifier extends ChangeNotifier {
  // Store Types
  String? _selectedStoreType;
  List<dynamic> _nearbyStores = [];
  bool _isLoadingStores = false;

  // Location
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoadingLocation = false;

  // Coverage Check
  bool _isCheckingCoverage = false;
  bool? _isInsideServiceArea;

  // SharedPreferences Key
  static const String _locationPostedKey = 'location_posted_once';

  // Getters
  String? get selectedStoreType => _selectedStoreType;
  List<dynamic> get nearbyStores => _nearbyStores;
  bool get isLoadingStores => _isLoadingStores;
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLoadingLocation => _isLoadingLocation;
  bool get isCheckingCoverage => _isCheckingCoverage;
  bool? get isInsideServiceArea => _isInsideServiceArea;

  // Initialize
  Future<void> initialize(BuildContext context) async {
    await _checkAndGetLocation(context);
  }

  // Store Type Selection
  void setSelectedStoreType(String? newValue) {
    _selectedStoreType = newValue;
    _nearbyStores = [];
    _isInsideServiceArea = null;
    _isCheckingCoverage = false;
    notifyListeners();
  }

  // Check and Get Location
  Future<void> _checkAndGetLocation(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool locationAlreadyPosted = prefs.getBool(_locationPostedKey) ?? false;

    if (!locationAlreadyPosted) {
      await getLocationWithAddress(context);
    } else {
      debugPrint('Location already posted. Skipping location fetch.');
    }
  }

  // Get Location with Address
  Future<void> getLocationWithAddress(BuildContext context) async {
    _isLoadingLocation = true;
    notifyListeners();

    try {
      Map<String, dynamic> locationData = await _locationService.getCurrentLocationWithAddress();
      Position position = locationData['position'];
      String fullAddress = locationData['address'];
      String shortAddr = await _locationService.getShortAddress(
        position.latitude,
        position.longitude,
      );

      _currentPosition = position;
      _currentAddress = fullAddress;
      _isLoadingLocation = false;
      notifyListeners();

      debugPrint('========== CURRENT LOCATION WITH ADDRESS ==========');
      debugPrint('Latitude: ${position.latitude}');
      debugPrint('Longitude: ${position.longitude}');
      debugPrint('Full Address: $fullAddress');
      debugPrint('Short Address: $shortAddr');
      debugPrint('==================================================');

      await _postLocationToApi(context, position.longitude, position.latitude, fullAddress);
      await _markLocationAsPosted();

      // Fetch profile after location is set
      final profileViewModel = ProfileViewViewModel();
      await profileViewModel.fetchProfileViewUserDataApi();
    } catch (e) {
      debugPrint('Error getting location with address: $e');
      _isLoadingLocation = false;
      notifyListeners();

      Utils.flushBarErrorMessage('Location error: ${e.toString()}', context);
    }
  }

  // Mark Location as Posted
  Future<void> _markLocationAsPosted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationPostedKey, true);
    debugPrint('Location marked as posted.');
  }

  // Post Location to API
  Future<void> _postLocationToApi(
      BuildContext context,
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

      final addLocationViewModel = AddLocationViewModel();
      await addLocationViewModel.addLocationPostApi(context, locationData);
      debugPrint('Location posted successfully to API');
    } catch (e) {
      debugPrint('Error posting location to API: $e');
      Utils.flushBarErrorMessage('Failed to save location: ${e.toString()}', context);
    }
  }

  // Fetch Nearby Retailers
  Future<void> fetchNearbyRetailers(
      BuildContext context,
      String businessType,
      ProfileViewViewModel profileViewModel,
      ) async {
    _isLoadingStores = true;
    _nearbyStores = [];
    notifyListeners();

    try {
      double? customerLng;
      double? customerLat;
      String? fullAddress;

      if (profileViewModel.profileviewUserData.status == Status.COMPLETED) {
        final addressData = profileViewModel.profileviewUserData.data?.data?.addresses;

        if (addressData?.geoLocation?.coordinates != null &&
            addressData!.geoLocation!.coordinates!.length >= 2) {
          customerLng = addressData.geoLocation!.coordinates![0];
          customerLat = addressData.geoLocation!.coordinates![1];
          fullAddress = addressData.fullAddress;
        }
      }

      if (customerLng == null || customerLat == null) {
        if (_currentPosition != null) {
          customerLng = _currentPosition!.longitude;
          customerLat = _currentPosition!.latitude;
          fullAddress ??= "Current Location";
        } else {
          Utils.flushBarErrorMessage(
            'Location not available. Please enable location services.',
            context,
          );
          _isLoadingStores = false;
          notifyListeners();
          return;
        }
      }

      final viewModel = PostNearbyRetailersViewModel();

      final requestData = {
        "deliveryAddress": {
          "geoLocation": {
            "type": "Point",
            "coordinates": [customerLng, customerLat],
          },
          "fullAddress": fullAddress ?? "",
        },
        "businessType": businessType,
      };

      List<dynamic>? stores = await viewModel.nearbyRetailersPostApi(context, requestData);

      if (stores != null && stores.isNotEmpty) {
        _nearbyStores = stores;
      }
    } catch (e) {
      Utils.flushBarErrorMessage("Failed to fetch nearby stores", context);
    } finally {
      _isLoadingStores = false;
      notifyListeners();
    }
  }

  // Check Coverage
  Future<void> checkCoverage(BuildContext context, CheckCoverageViewModel checkCoverageViewModel) async {
    _isCheckingCoverage = true;
    _isInsideServiceArea = null;
    notifyListeners();

    try {
      await checkCoverageViewModel.fetchCheckCoverageDataApi();

      if (checkCoverageViewModel.checkCoverageData.status == Status.COMPLETED) {
        final responseData = checkCoverageViewModel.checkCoverageData.data;

        if (responseData?.data?.insideServiceArea == true) {
          _isInsideServiceArea = true;
          _isCheckingCoverage = false;
          notifyListeners();
        } else {
          _isInsideServiceArea = false;
          _isCheckingCoverage = false;
          notifyListeners();
        }
      } else if (checkCoverageViewModel.checkCoverageData.status == Status.ERROR) {
        _isInsideServiceArea = false;
        _isCheckingCoverage = false;
        notifyListeners();
        Utils.flushBarErrorMessage("Failed to check service coverage", context);
      } else {
        await Future.delayed(Duration(milliseconds: 500));
        await checkCoverage(context, checkCoverageViewModel);
      }
    } catch (e) {
      _isInsideServiceArea = false;
      _isCheckingCoverage = false;
      notifyListeners();
      Utils.flushBarErrorMessage("Failed to check service coverage", context);
    }
  }

  // Handle Refresh
  Future<void> handleRefresh(
      BuildContext context,
      ProfileViewViewModel profileViewModel,
      ) async {
    try {
      debugPrint('🔄 HomeNotifier: Pull to refresh triggered');

      // Force refresh profile data
      await profileViewModel.refreshProfileData();

      // If Retail is selected, refresh nearby retailers
      if (_selectedStoreType == 'Retail') {
        await fetchNearbyRetailers(context, _selectedStoreType!, profileViewModel);
      }
    } catch (e) {
      Utils.flushBarErrorMessage("Refresh failed", context);
    }
  }

  // Reset state
  void reset() {
    _selectedStoreType = null;
    _nearbyStores = [];
    _isLoadingStores = false;
    _isCheckingCoverage = false;
    _isInsideServiceArea = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up resources if needed
    debugPrint('HomeNotifier disposed');
    super.dispose();
  }
}