import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/services/location_services/location_getting.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/post_newlocation_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/post_change_passwordview_model/post_change_passwordview_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class AddNewlocationScreen extends StatefulWidget {
  const AddNewlocationScreen({super.key});

  @override
  State<AddNewlocationScreen> createState() => _AddNewlocationScreenState();
}

class _AddNewlocationScreenState extends State<AddNewlocationScreen> {
  // Location related variables
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  String? _currentAddress;
  String? _shortAddress;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
  }

  String _locationMessage = "Location not fetched yet.";

  Future<void> _getLocationWithAddress() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Get location and address
      Map<String, dynamic> locationData = await _locationService.getCurrentLocationWithAddress();
      Position position = locationData['position'];
      String fullAddress = locationData['address'];

      // Get short address for app bar
      String shortAddr = await _locationService.getShortAddress(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _currentAddress = fullAddress;
          _shortAddress = shortAddr;
          _locationMessage = "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
          _isLoadingLocation = false;
        });

        // Print detailed location info in terminal
        debugPrint('========== CURRENT LOCATION WITH ADDRESS ==========');
        debugPrint('Latitude: ${position.latitude}');
        debugPrint('Longitude: ${position.longitude}');
        debugPrint('Full Address: $fullAddress');
        debugPrint('Short Address: $shortAddr');
        debugPrint('Accuracy: ${position.accuracy} meters');
        debugPrint('Altitude: ${position.altitude} meters');
        debugPrint('Timestamp: ${position.timestamp}');
        debugPrint('==================================================');

        // *** AUTOMATICALLY POST LOCATION TO API ***
        await _postLocationToApi(position.longitude, position.latitude, fullAddress);
      }
    } catch (e) {
      debugPrint('Error getting location with address: $e');
      if (mounted) {
        setState(() {
          _locationMessage = "Please enable location to use this app.";
          _isLoadingLocation = false;
        });

        // Show error message to user
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

  // Method to post location data to API
  Future<void> _postLocationToApi(double longitude, double latitude, String fullAddress) async {
    try {
      final locationData = {
        "geoLocation": {
          "type": "Point",
          "coordinates": [longitude, latitude]
        },
        "fullAddress": fullAddress
      };

      final addLocationViewModel = Provider.of<AddLocationViewModel>(context, listen: false);
      await addLocationViewModel.addLocationPostApi(context, locationData);

      debugPrint('Location data to post: $locationData');

      // Show success message
      if (mounted) {
        Utils.flushBarSuccessMessage('Location saved successfully', context);
      }
    } catch (e) {
      debugPrint('Error posting location to API: $e');

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save location: ${e.toString()}'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
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
        child: ResPonsiveUi(
          mobile: body(),
          desktop: body(),
          tablet: body(),
        ),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return Column(
      children: [
        // App Bar Header
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: 60,
            color: AppColors.containerBackground(context),
            child: AppBarHeader("Your Location"),
          ),
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
                      border: Border.all(
                        color: AppColors.button(context),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              FontAwesomeIcons.mapLocation,
                              color: AppColors.button(context),
                              size: 20
                          ),
                          SizedboxSpaccing.width03(context),
                          Text(
                              "Set Your Location",
                              style: AppTextStyles.textSize16(
                                  context,
                                  weight: FontWeight.w600,
                                  color: AppColors.button(context)
                              )
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
                          child: Container(
                            height: 1,
                            width: screenWidth * 0.41,
                            color: AppColors.border(context),
                          ),
                        ),
                      ),
                      Text(
                        "or",
                        style: AppTextStyles.textSize14(
                            context,
                            weight: FontWeight.w500,
                            color: AppColors.subtitle(context)
                        ),
                      ),
                      Container(
                        height: 20,
                        child: Center(
                          child: Container(
                            height: 1,
                            width: screenWidth * 0.41,
                            color: AppColors.border(context),
                          ),
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
                      onTap: (_isLoadingLocation || addLocationProvider.createAddLocationLoading)
                          ? null
                          : _getLocationWithAddress,
                      child: Container(
                        width: screenWidth * 0.8,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.button(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: (_isLoadingLocation || addLocationProvider.createAddLocationLoading)
                              ? Container(
                              height: 15,
                              width: 50,
                              child: LoadingAnimationWidget.progressiveDots(
                                  color: AppColors.whiteColor,
                                  size: 45
                              )
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                  FontAwesomeIcons.locationArrow,
                                  color: AppColors.whiteColor,
                                  size: 20
                              ),
                              SizedboxSpaccing.width03(context),
                              Text(
                                  "Use Current Location",
                                  style: AppTextStyles.textSize16(
                                      context,
                                      weight: FontWeight.w600,
                                      color: AppColors.whiteColor
                                  )
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedboxSpaccing.height025(context),

                // Current Location Display (if available)
                // if (_currentAddress != null)
                //   Container(
                //     width: screenWidth * 0.9,
                //     padding: EdgeInsets.all(16),
                //     decoration: BoxDecoration(
                //       color: AppColors.button(context).withOpacity(0.05),
                //       borderRadius: BorderRadius.circular(8),
                //       border: Border.all(
                //         color: AppColors.button(context).withOpacity(0.2),
                //         width: 1,
                //       ),
                //     ),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Row(
                //           children: [
                //             Icon(
                //               FontAwesomeIcons.locationDot,
                //               color: AppColors.button(context),
                //               size: 16,
                //             ),
                //             SizedboxSpaccing.width02(context),
                //             Text(
                //               "Current Location",
                //               style: AppTextStyles.textSize16(
                //                   context,
                //                   weight: FontWeight.w600,
                //                   color: AppColors.button(context)
                //               ),
                //             ),
                //           ],
                //         ),
                //         SizedboxSpaccing.height01(context),
                //         Text(
                //           _currentAddress!,
                //           style: AppTextStyles.textSize14(
                //               context,
                //               weight: FontWeight.w400,
                //               color: AppColors.subtitle(context)
                //           ),
                //         ),
                //         if (_currentPosition != null) ...[
                //           SizedboxSpaccing.height005(context),
                //           Text(
                //             "Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Long: ${_currentPosition!.longitude.toStringAsFixed(6)}",
                //             style: AppTextStyles.textSize12(
                //                 context,
                //                 weight: FontWeight.w400,
                //                 color: AppColors.subtitle(context).withOpacity(0.7)
                //             ),
                //           ),
                //         ]
                //       ],
                //     ),
                //   ),
                //
                // SizedboxSpaccing.height025(context),

                // Saved Addresses Section
                Container(
                  width: screenWidth * 0.9,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "Saved Address",
                              style: AppTextStyles.textSize18(
                                  context,
                                  weight: FontWeight.w500
                              )
                          ),
                          SizedBox()
                        ],
                      ),
                      SizedboxSpaccing.height005(context),
                      Divider(
                          height: 1,
                          color: AppColors.border(context)
                      ),
                    ],
                  ),
                ),

                SizedboxSpaccing.height02(context),

                // Location Status Message (for debugging)
                if (_locationMessage.isNotEmpty && _currentAddress == null)
                  Container(
                    width: screenWidth * 0.9,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _locationMessage,
                      style: AppTextStyles.textSize14(
                          context,
                          weight: FontWeight.w400,
                          color: AppColors.subtitle(context)
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}