import 'dart:async';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/newlocation_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MapLocationScreen extends StatefulWidget {
  const MapLocationScreen({super.key});

  @override
  State<MapLocationScreen> createState() => _MapLocationScreenState();
}

class _MapLocationScreenState extends State<MapLocationScreen> {
  // Google Maps Controller
  Completer<GoogleMapController> _controller = Completer();

  // Map and Location Variables
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(22.3569, 91.7832), // Chittagong coordinates
    zoom: 14.4746,
  );

  LatLng? _selectedLocation;
  Set<Marker> _markers = {};
  String _selectedAddress = '';
  bool _isLoadingAddress = false;
  bool _isLoadingCurrentLocation = false;

  // Text Field Controller
  TextEditingController _addressController = TextEditingController();
  FocusNode _addressFocusNode = FocusNode();

  // Google Places API Key - Replace with your actual API key
  static const String _googlePlacesApiKey = 'REMOVED_KEY';

  // Map theme variables
  String? _darkMapTheme;
  String? _lightMapTheme;

  @override
  void initState() {
    super.initState();
    _loadMapThemes();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  // Load map themes from assets
  Future<void> _loadMapThemes() async {
    try {
      _darkMapTheme = await rootBundle.loadString('assets/map_theme/nighttheme.json');
      _lightMapTheme = await rootBundle.loadString('assets/map_theme/standaredtheme.json');
    } catch (e) {
      debugPrint('Error loading map themes: $e');
    }
  }

  // Method to check if current theme is dark
  bool get _isDarkMode {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Method to get current map theme
  String? get _currentMapTheme {
    if (_isDarkMode) {
      return _darkMapTheme;
    } else {
      return _lightMapTheme;
    }
  }

  // Method to apply map style based on theme
  Future<void> _setMapStyle() async {
    if (_controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;
      final String? theme = _currentMapTheme;
      if (theme != null) {
        await controller.setMapStyle(theme);
      }
    }
  }

  // Update your onMapCreated method
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    // Apply theme immediately when map is created
    _setMapStyle();
  }

  // Update your didChangeDependencies method
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reapply style when theme changes
    _setMapStyle();
  }

  // Get current location_screens
  // Future<void> _getCurrentLocation() async {
  //   setState(() {
  //     _isLoadingCurrentLocation = true;
  //   });
  //
  //   try {
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       throw Exception('Location services are disabled.');
  //     }
  //
  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         throw Exception('Location permissions are denied');
  //       }
  //     }
  //
  //     if (permission == LocationPermission.deniedForever) {
  //       throw Exception('Location permissions are permanently denied');
  //     }
  //
  //     Position position = await Geolocator.getCurrentPosition();
  //     LatLng currentLocation = LatLng(position.latitude, position.longitude);
  //
  //     await _updateSelectedLocation(currentLocation);
  //
  //     // Move camera to current location_screens
  //     final GoogleMapController controller = await _controller.future;
  //     controller.animateCamera(
  //       CameraUpdate.newCameraPosition(
  //         CameraPosition(
  //           target: currentLocation,
  //           zoom: 16.0,
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     debugPrint('Error getting current location_screens: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error getting current location_screens: ${e.toString()}'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } finally {
  //     setState(() {
  //       _isLoadingCurrentLocation = false;
  //     });
  //   }
  // }
  // Replace the existing _getCurrentLocation method with this updated version

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      // Check if location_screens services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLoadingCurrentLocation = false;
          });

          // Show dialog for location_screens services
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Location Services Disabled'),
                content: Text('Please enable location_screens services to use this feature.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await Geolocator.openLocationSettings();
                    },
                    child: Text('Open Settings'),
                  ),
                ],
              );
            },
          );
        }
        return;
      }

      // Check location_screens permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isLoadingCurrentLocation = false;
            });

            // Directly open app settings when permission is denied
            await Geolocator.openAppSettings();
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoadingCurrentLocation = false;
          });

          // Directly open app settings when permission is permanently denied
          await Geolocator.openAppSettings();
        }
        return;
      }

      // If we reach here, we have permission - get current location_screens
      Position position = await Geolocator.getCurrentPosition();
      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      await _updateSelectedLocation(currentLocation);

      // Move camera to current location_screens
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: currentLocation, zoom: 16.0)));
    } catch (e) {
      debugPrint('Error getting current location_screens: $e');
      if (mounted) {
        setState(() {
          _isLoadingCurrentLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error getting current location_screens: ${e.toString()}'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCurrentLocation = false;
        });
      }
    }
  }

  // Update selected location_screens and get address
  Future<void> _updateSelectedLocation(LatLng location) async {
    setState(() {
      _selectedLocation = location;
      _isLoadingAddress = true;
      _markers = {
        Marker(
          markerId: const MarkerId('selected-location_screens'),
          position: location,
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            _updateSelectedLocation(newPosition);
          },
          infoWindow: InfoWindow(title: 'Selected Location', snippet: 'Tap to get address'),
        ),
      };
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}';

        setState(() {
          _selectedAddress = address.replaceAll(RegExp(r'^, |, $'), '');
          _addressController.text = _selectedAddress;
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      setState(() {
        _selectedAddress = 'Address not found';
        _addressController.text = _selectedAddress;
      });
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  // Handle map tap
  void _onMapTap(LatLng location) {
    _updateSelectedLocation(location);
  }

  // Handle place selection from Google Places API
  void _onPlaceSelected(Prediction prediction) async {
    try {
      List<Location> locations = await locationFromAddress(prediction.description!);
      if (locations.isNotEmpty) {
        LatLng selectedLocation = LatLng(locations.first.latitude, locations.first.longitude);

        await _updateSelectedLocation(selectedLocation);

        // Move camera to selected location_screens
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: selectedLocation, zoom: 16.0)));

        // Unfocus the text field
        _addressFocusNode.unfocus();
      }
    } catch (e) {
      debugPrint('Error selecting place: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error selecting place: ${e.toString()}'), backgroundColor: Colors.red));
    }
  }

  // Confirm location_screens selection
  // void _confirmLocation() async {
  //   if (_selectedLocation != null && _selectedAddress.isNotEmpty) {
  //     try {
  //       final locationData = {
  //         "geoLocation": {
  //           "type": "Point",
  //           "coordinates": [_selectedLocation!.longitude, _selectedLocation!.latitude],
  //         },
  //         "fullAddress": _selectedAddress,
  //         "type": "DELIVERY_ADDRESS",
  //       };
  //
  //       final addLocationViewModel = Provider.of<AddLocationViewModel>(context, listen: false);
  //       await addLocationViewModel.addLocationPostApi(context, locationData);
  //
  //       if (mounted) {
  //         Utils.flushBarSuccessMessage('Location saved successfully', context);
  //         Future.delayed(const Duration(milliseconds: 1000), () {
  //           Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen()));
  //         });
  //       }
  //     } catch (e) {
  //       debugPrint('Error saving location_screens: $e');
  //       if (mounted) {
  //         Utils.flushBarErrorMessage('Failed to save location_screens', context);
  //       }
  //     }
  //   } else {
  //     Utils.flushBarErrorMessage('Please select a location_screens', context);
  //   }
  // }
// Replace your _confirmLocation method with this updated version:

  void _confirmLocation() async {
    if (_selectedLocation != null && _selectedAddress.isNotEmpty) {
      try {
        final locationData = {
          "geoLocation": {
            "type": "Point",
            "coordinates": [_selectedLocation!.longitude, _selectedLocation!.latitude]
          },
          "fullAddress": _selectedAddress,
          "type": "DELIVERY_ADDRESS",
        };

        final addLocationViewModel = Provider.of<AddLocationViewModel>(context, listen: false);
        await addLocationViewModel.addLocationPostApi(context, locationData);


      } catch (e) {
        debugPrint('Error saving location_screens: $e');
        if (mounted) {
          Utils.flushBarErrorMessage('Failed to save location_screens', context);
        }
      }
    } else {
      Utils.flushBarErrorMessage('Please select a location_screens', context);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedboxSpaccing.height005(context),
        Container(
          width: screenWidth * 0.9,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(height: 20, width: 24, alignment: Alignment.centerLeft, child: SvgPicture.asset("assets/images/header_arrow.svg")),
              ),
              Container(
                width: screenWidth * 0.7,
                // color: Colors.green,
                child: GooglePlaceAutoCompleteTextField(
                  textEditingController: _addressController,
                  googleAPIKey: _googlePlacesApiKey,
                  isCrossBtnShown: false, // This removes the built-in cancel button
                  inputDecoration: InputDecoration(
                    hintText: 'Search for a location_screens...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    isDense: true,
                    fillColor: AppColors.globalBlackWhite(context),
                    filled: true,
                  ),
                  boxDecoration: BoxDecoration(
                    border: Border.all(color: AppColors.border(context), width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  debounceTime: 400,
                  countries: ["bd"], // Restrict to Bangladesh
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (Prediction prediction) {
                    _onPlaceSelected(prediction);
                  },
                  itemClick: (Prediction prediction) {
                    _addressController.text = prediction.description!;
                    _onPlaceSelected(prediction);
                  },
                  seperatedBuilder: Divider(color: AppColors.border(context), height: 1),
                  containerHorizontalPadding: 5,
                  itemBuilder: (context, index, Prediction prediction) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: AppColors.textFieldFill(context),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.locationDot, color: AppColors.button(context), size: 16),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prediction.structuredFormatting?.mainText ?? prediction.description!,
                                  style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (prediction.structuredFormatting?.secondaryText != null)
                                  Text(
                                    prediction.structuredFormatting!.secondaryText!,
                                    style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Clear the text field and reset related states
                  _addressController.clear();
                  setState(() {
                    _selectedLocation = null;
                    _markers.clear();
                    _selectedAddress = '';
                  });
                  // Optional: Move camera back to initial position
                  // _controller.future.then((GoogleMapController controller) {
                  //   controller.animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
                  // });
                },
                child: Container(height: 20, width: 24, alignment: Alignment.centerLeft, child: Icon(FontAwesomeIcons.x, size: 18)),
              ),
            ],
          ),
        ),
        SizedboxSpaccing.height005(context),

        // Google Map
        Expanded(
          child: Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: _onMapCreated, // Use the updated method
                onTap: _onMapTap,
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                compassEnabled: true,
                mapToolbarEnabled: false,
                // Note: We're not setting style here since we handle it programmatically
              ),

              // Current Location Button
              Positioned(
                top: 16,
                right: 16,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: AppColors.button(context),
                  onPressed: _isLoadingCurrentLocation ? null : _getCurrentLocation,
                  child: _isLoadingCurrentLocation ? LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 20) : Icon(FontAwesomeIcons.locationCrosshairs, color: Colors.white, size: 18),
                ),
              ),

              // Selected Location Info Card
              if (_selectedLocation != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.containerBackground(context), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(FontAwesomeIcons.locationDot, color: AppColors.button(context), size: 16),
                              SizedBox(width: 8),
                              Text(
                                "Selected Location",
                                style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            _selectedAddress.isNotEmpty ? _selectedAddress : 'Getting address...',
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                            style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context).withOpacity(0.7)),
                          ),
                          SizedBox(height: 12),
                          Consumer<AddLocationViewModel>(
                            builder: (context, addLocationProvider, child) {
                              return SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: (addLocationProvider.createAddLocationLoading || _isLoadingAddress) ? null : _confirmLocation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.button(context),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: addLocationProvider.createAddLocationLoading
                                      ? LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 20)
                                      : Text(
                                          'Confirm Location',
                                          style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
