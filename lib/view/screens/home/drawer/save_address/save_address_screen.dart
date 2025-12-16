import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/get_locationlist_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/newlocation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
class SaveAddressScreen extends StatefulWidget {
  const SaveAddressScreen({super.key});

  @override
  State<SaveAddressScreen> createState() => _SaveAddressScreenState();
}


class _SaveAddressScreenState extends State<SaveAddressScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetLocationListViewModel>(context, listen: false).fetchLocationListApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
          child: ResPonsiveUi(
              mobile: body(),
              desktop: body(),
              tablet: body()
          )
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
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>NavigationScreen(initialIndex: 0)));
                },
                child: AppBarHeader("Save Addresses"),
              ),
              Center(child: SizedboxSpaccing.height025(context)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Location List Section
                      _buildLocationListSection(screenWidth, screenHeight),
                      SizedboxSpaccing.height025(context),
                    ],
                  ),
                ),
              ),
            ]),
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
                          "Set Address",
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

  String? _selectedLocationId;
  dynamic _selectedLocationData;
  bool _isUpdating = false;
  bool _isDeleting = false;


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

      if (mounted) {
        // Refresh the location_screens list
        Provider.of<GetLocationListViewModel>(context, listen: false).fetchLocationListApi();

        Utils.flushBarSuccessMessage('Location updated successfully', context);

        Future.delayed(const Duration(milliseconds: 1000), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen()));
        });
        setState(() {
          _selectedLocationId = null;
          _selectedLocationData = null;
          _isUpdating = false;
        });
      }
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

}
