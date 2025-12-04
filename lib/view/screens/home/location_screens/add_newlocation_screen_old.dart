import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/services/location_services/location_getting.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/get_locationlist_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/newlocation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddNewlocationScreenOld extends StatefulWidget {
  const AddNewlocationScreenOld({super.key});

  @override
  State<AddNewlocationScreenOld> createState() => _AddNewlocationScreenOldState();
}

class _AddNewlocationScreenOldState extends State<AddNewlocationScreenOld> {
  // Location related variables
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  String? _currentAddress;
  String? _shortAddress;
  bool _isLoadingLocation = false;

  // Selection related variables
  String? _selectedLocationId;
  dynamic _selectedLocationData;
  bool _isUpdating = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetLocationListViewModel>(context, listen: false).fetchLocationListApi();
    });
  }

  String _locationMessage = "Location not fetched yet.";

  // Method to handle location_screens selection
  void _selectLocation(String locationId, dynamic locationData) {
    setState(() {
      if (_selectedLocationId == locationId) {
        // Deselect if already selected
        _selectedLocationId = null;
        _selectedLocationData = null;
      } else {
        // Select new location_screens
        _selectedLocationId = locationId;
        _selectedLocationData = locationData;
      }
    });
  }

  // Method to update selected location_screens
  Future<void> _updateSelectedLocation() async {
    if (_selectedLocationData == null) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final coordinates = _selectedLocationData.geoLocation?.coordinates ?? [];
      if (coordinates.length < 2) {
        throw Exception('Invalid coordinates');
      }

      // Get the location_screens ID from selected location_screens data
      final String locationId = _selectedLocationData.id ?? '';

      if (locationId.isEmpty) {
        throw Exception('Location ID not found');
      }

      final locationData = {
        "default":true,
        "geoLocation": {
          "type": "Point",
          "coordinates": [coordinates[0], coordinates[1]], // [longitude, latitude]
        },
        "fullAddress": _selectedLocationData.fullAddress ?? '',
        "type": _selectedLocationData.type ?? "DELIVERY_ADDRESS",
      };

      final addLocationViewModel = Provider.of<AddLocationViewModel>(context, listen: false);

      // Pass locationId as the userId parameter
      await addLocationViewModel.updateAddressPatchApi(context, locationData, locationId);

      debugPrint('Updated location_screens data: $locationData');
      debugPrint('Location ID: $locationId');

      // if (mounted) {
      //   // Refresh the location_screens list
      //   Provider.of<GetLocationListViewModel>(context, listen: false).fetchLocationListApi();
      //
      //   Utils.flushBarSuccessMessage('Location updated successfully', context);
      //
      //   Future.delayed(const Duration(milliseconds: 1000), () {
      //     Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen()));
      //   });
      //   setState(() {
      //     _selectedLocationId = null;
      //     _selectedLocationData = null;
      //     _isUpdating = false;
      //   });
      // }
    } catch (e) {
      debugPrint('Error updating location_screens: $e');

      if (mounted) {
        setState(() {
          _isUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update location_screens: ${e.toString()}'), backgroundColor: Colors.orange, duration: Duration(seconds: 3)));
      }
    }
  }

  // Future<void> _getLocationWithAddress() async {
  //   if (!mounted) return;
  //
  //   setState(() {
  //     _isLoadingLocation = true;
  //   });
  //
  //   try {
  //     Map<String, dynamic> locationData = await _locationService.getCurrentLocationWithAddress();
  //     Position position = locationData['position'];
  //     String fullAddress = locationData['address'];
  //     String shortAddr = await _locationService.getShortAddress(position.latitude, position.longitude);
  //
  //     if (mounted) {
  //       setState(() {
  //         _currentPosition = position;
  //         _currentAddress = fullAddress;
  //         _shortAddress = shortAddr;
  //         _locationMessage = "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
  //         _isLoadingLocation = false;
  //       });
  //
  //       debugPrint('========== CURRENT LOCATION WITH ADDRESS ==========');
  //       debugPrint('Latitude: ${position.latitude}');
  //       debugPrint('Longitude: ${position.longitude}');
  //       debugPrint('Full Address: $fullAddress');
  //       debugPrint('Short Address: $shortAddr');
  //       debugPrint('==================================================');
  //
  //       await _postLocationToApi(position.longitude, position.latitude, fullAddress);
  //     }
  //   } catch (e) {
  //     debugPrint('Error getting location_screens with address: $e');
  //     if (mounted) {
  //       setState(() {
  //         _locationMessage = "Please enable location_screens to use this app.";
  //         _isLoadingLocation = false;
  //       });
  //
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location error: ${e.toString()}'), backgroundColor: Colors.red, duration: Duration(seconds: 3)));
  //     }
  //   }
  // }
// Replace the existing _getLocationWithAddress method with this updated version

  Future<void> _getLocationWithAddress() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location_screens services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
            _locationMessage = "Location services are disabled.";
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
              _isLoadingLocation = false;
              _locationMessage = "Location permission denied.";
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
            _isLoadingLocation = false;
            _locationMessage = "Location permission permanently denied.";
          });

          // Directly open app settings when permission is permanently denied
          await Geolocator.openAppSettings();
        }
        return;
      }

      // If we reach here, we have permission - proceed with getting location_screens
      Map<String, dynamic> locationData = await _locationService.getCurrentLocationWithAddress();
      Position position = locationData['position'];
      String fullAddress = locationData['address'];
      String shortAddr = await _locationService.getShortAddress(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _currentAddress = fullAddress;
          _shortAddress = shortAddr;
          _locationMessage = "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
          _isLoadingLocation = false;
        });

        debugPrint('========== CURRENT LOCATION WITH ADDRESS ==========');
        debugPrint('Latitude: ${position.latitude}');
        debugPrint('Longitude: ${position.longitude}');
        debugPrint('Full Address: $fullAddress');
        debugPrint('Short Address: $shortAddr');
        debugPrint('==================================================');

        await _postLocationToApi(position.longitude, position.latitude, fullAddress);
      }
    } catch (e) {
      debugPrint('Error getting location_screens with address: $e');
      if (mounted) {
        setState(() {
          _locationMessage = "Please enable location_screens to use this app.";
          _isLoadingLocation = false;
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
  }
  Future<void> _postLocationToApi(double longitude, double latitude, String fullAddress) async {
    try {
      final locationData = {
        "geoLocation": {
          "type": "Point",
          "coordinates": [longitude, latitude],
        },
        "fullAddress": fullAddress,
        "type": "DELIVERY_ADDRESS",
      };

      final addLocationViewModel = Provider.of<AddLocationViewModel>(context, listen: false);
      await addLocationViewModel.addLocationPostApi(context, locationData);

      debugPrint('Location data to post: $locationData');

      // if (mounted) {
      //   Provider.of<GetLocationListViewModel>(context, listen: false).fetchLocationListApi();
      //   Utils.flushBarSuccessMessage('Location saved successfully', context);
      //   Future.delayed(const Duration(milliseconds: 1000), () {
      //     Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen()));
      //   });
      // }
    } catch (e) {
      debugPrint('Error posting location_screens to API: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save location_screens: ${e.toString()}'), backgroundColor: Colors.orange, duration: Duration(seconds: 3)));
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
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

  @override
  void dispose() {
    super.dispose();
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
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return Stack(
      children: [
        Column(
          children: [
            // App Bar Header
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(height: 60, color: AppColors.containerBackground(context), child: AppBarHeader("Your Location")),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedboxSpaccing.height025(context),

                    // Set Location Button (Navigate to Map)
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, RoutesName.mapLocationScreen);
                      },
                      child: Container(
                        width: screenWidth * 0.8,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.button(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.whiteColor : AppColors.button(context), width: 1),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.mapLocation, color: Theme.of(context).brightness == Brightness.dark ? AppColors.whiteColor : AppColors.button(context), size: 20),
                              SizedboxSpaccing.width03(context),
                              Text(
                                "Set Your Location",
                                style: AppTextStyles.textSize16(
                                  context,
                                  weight: FontWeight.w600,
                                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.whiteColor : AppColors.button(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedboxSpaccing.height025(context),

                    // Divider with "or" text
                    Container(
                      width: screenWidth * 0.9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 20,
                            child: Center(
                              child: Container(height: 1, width: screenWidth * 0.41, color: AppColors.border(context)),
                            ),
                          ),
                          Text(
                            "or",
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.subtitle(context)),
                          ),
                          Container(
                            height: 20,
                            child: Center(
                              child: Container(height: 1, width: screenWidth * 0.41, color: AppColors.border(context)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedboxSpaccing.height025(context),

                    // Use Current Location Button with Consumer
                    Consumer<AddLocationViewModel>(
                      builder: (context, addLocationProvider, child) {
                        return GestureDetector(
                          onTap: (_isLoadingLocation || addLocationProvider.createAddLocationLoading) ? null : _getLocationWithAddress,
                          child: Container(
                            width: screenWidth * 0.8,
                            height: 50,
                            decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: (_isLoadingLocation || addLocationProvider.createAddLocationLoading)
                                  ? Container(height: 15, width: 50, child: LoadingAnimationWidget.progressiveDots(color: AppColors.whiteColor, size: 45))
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.locationArrow, color: AppColors.whiteColor, size: 20),
                                  SizedboxSpaccing.width03(context),
                                  Text(
                                    "Use Current Location",
                                    style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedboxSpaccing.height02(context),

                    // Location List Section
                    _buildLocationListSection(screenWidth, screenHeight),

                    // Add extra space at bottom for update button
                    SizedBox(height: _selectedLocationId != null ? 100 : 25),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Update Address Button (Fixed at bottom)
        if (_selectedLocationId != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.containerBackground(context),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    // onTap: _isDeleting ? null : _updateSelectedLocation,
                    child: Container(
                      width: screenWidth * 0.4,
                      height: 42,
                      decoration: BoxDecoration(color: AppColors.darkRedColor, borderRadius: BorderRadius.circular(12)),
                      child: Center(
                        child: _isDeleting
                            ? Container(height: 15, width: 50, child: LoadingAnimationWidget.progressiveDots(color: AppColors.whiteColor, size: 45))
                            : Text(
                          "Delete",
                          style: AppTextStyles.textSize14(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isUpdating ? null : _updateSelectedLocation,
                    child: Container(
                      width: screenWidth * 0.4,
                      height: 42,
                      decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(12)),
                      child: Center(
                        child: _isUpdating
                            ? Container(height: 15, width: 50, child: LoadingAnimationWidget.progressiveDots(color: AppColors.whiteColor, size: 45))
                            : Text(
                          "Update Address",
                          style: AppTextStyles.textSize14(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLocationListSection(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Container(
          width: screenWidth * 0.9,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Saved Addresses", style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
                  SizedBox(),
                ],
              ),
              SizedboxSpaccing.height005(context),
              Divider(height: 1, color: AppColors.border(context)),
            ],
          ),
        ),
        SizedboxSpaccing.height015(context),
        Consumer<GetLocationListViewModel>(
          builder: (context, locationViewModel, child) {
            return Container(
              width: screenWidth * 0.9,
              child: switch (locationViewModel.locationListData.status) {
                Status.LOADING => Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 1, color: AppColors.border(context)),
                  ),
                  child: Center(
                    child: Container(height: 15, width: 50, child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45)),
                  ),
                ),
                Status.ERROR => Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 1, color: AppColors.border(context)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 24),
                        SizedBox(height: 8),
                        Text('Failed to load locations', style: AppTextStyles.textSize14(context, color: Colors.red)),
                      ],
                    ),
                  ),
                ),
                Status.COMPLETED => () {
                  final locationList = locationViewModel.locationListData.data?.data ?? [];

                  if (locationList.isEmpty) {
                    return Container(
                      width: screenWidth * 0.9,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.textFieldFill(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(width: 1, color: AppColors.border(context)),
                      ),
                      child: Center(
                        child: Text(
                          "No Saved Locations",
                          style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.form_hover(context)),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: locationList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: index < locationList.length - 1 ? screenHeight * 0.015 : 0),
                        child: _buildLocationItemCard(locationList[index], screenWidth, screenHeight),
                      );
                    },
                  );
                }(),
                _ => Container(),
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationItemCard(dynamic locationData, double screenWidth, double screenHeight) {
    final fullAddress = locationData.fullAddress ?? 'Unknown Address';
    final coordinates = locationData.geoLocation?.coordinates ?? [];
    final createdAt = locationData.createdAt;
    final locationType = locationData.type ?? 'DELIVERY_ADDRESS';
    final locationId = locationData.id ?? '';

    final isSelected = _selectedLocationId == locationId;

    return GestureDetector(
      onTap: () => _selectLocation(locationId, locationData),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(screenHeight * 0.015),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.button(context).withOpacity(0.05) : AppColors.containerBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: isSelected ? 1 : 1, color: isSelected ? AppColors.button(context) : AppColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: isSelected ? AppColors.button(context).withOpacity(0.1) : AppColors.textFieldFill(context)),
                  child: Center(child: Icon(FontAwesomeIcons.mapLocationDot, size: 20, color: AppColors.darkRedColor.withOpacity(0.7))),
                ),
                SizedboxSpaccing.width03(context),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locationType.replaceAll('_', ' '),
                        style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
                      ),
                      Text(
                        fullAddress,
                        style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.form_hover(context)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
                    child: Icon(Icons.check, color: AppColors.whiteColor, size: 16),
                  ),
              ],
            ),
            SizedboxSpaccing.height005(context),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (coordinates.length >= 2)
                // Expanded(
                //   child: Text(
                //     'Lat: ${coordinates[1].toStringAsFixed(4)}, Long: ${coordinates[0].toStringAsFixed(4)}',
                //     style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                //     overflow: TextOverflow.ellipsis,
                //   ),
                // ),
                  SizedBox(),

                if (createdAt != null)
                  Text(
                    _formatDateTime(createdAt),
                    style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
