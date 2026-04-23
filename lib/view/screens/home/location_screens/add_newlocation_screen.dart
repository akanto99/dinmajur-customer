// add_newlocation_screen.dart
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/exception_errorstate/exception_errorstate.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view/screens/home/location_screens/controller/add_newLocationscreen_controller.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/get_locationlist_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/newlocation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class AddNewlocationScreen extends StatefulWidget {
  const AddNewlocationScreen({super.key});

  @override
  State<AddNewlocationScreen> createState() => _AddNewlocationScreenState();
}

class _AddNewlocationScreenState extends State<AddNewlocationScreen> {
  late AddNewLocationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AddNewLocationController(context, setState);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initialize();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(mobile: _buildBody(), desktop: _buildBody(), tablet: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Column(
          children: [
            // App Bar Header
            GestureDetector(
              onTap: _controller.navigateBack,
              child: Container(height: 60, color: AppColors.containerBackground(context), child: AppBarHeader("Your Location")),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedboxSpaccing.height025(context),
                    _buildSetLocationButton(screenWidth),
                    SizedboxSpaccing.height025(context),
                    _buildDivider(screenWidth),
                    SizedboxSpaccing.height025(context),
                    _buildCurrentLocationButton(screenWidth),
                    SizedboxSpaccing.height02(context),
                    _buildLocationListSection(screenWidth, screenHeight),
                    SizedBox(height: _controller.selectedLocationId != null ? 100 : 25),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Update/Delete Buttons (Fixed at bottom)
        if (_controller.selectedLocationId != null) _buildBottomActionButtons(screenWidth),
      ],
    );
  }

  Widget _buildSetLocationButton(double screenWidth) {
    return GestureDetector(
      onTap: _controller.navigateToMapScreen,
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
                style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Theme.of(context).brightness == Brightness.dark ? AppColors.whiteColor : AppColors.button(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(double screenWidth) {
    return Container(
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
    );
  }

  Widget _buildCurrentLocationButton(double screenWidth) {
    return Consumer<AddLocationViewModel>(
      builder: (context, addLocationProvider, child) {
        final isLoading = _controller.isLoadingLocation || addLocationProvider.createAddLocationLoading;

        return GestureDetector(
          onTap: isLoading ? null : _controller.getLocationWithAddress,
          child: Container(
            width: screenWidth * 0.8,
            height: 50,
            decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: isLoading
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
                Status.LOADING => _buildLoadingState(),
                Status.ERROR => _buildErrorState(),
                Status.COMPLETED => _buildLocationList(locationViewModel, screenWidth, screenHeight),
                _ => Container(),
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Center(
        child: Container(height: 15, width: 50, child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45)),
      ),
    );
  }

  Widget _buildErrorState() {
    return ErrorStateWidget(
      errorMessage:'Failed to load locations',
      onRetry: () {
        Provider.of<GetLocationListViewModel>(context, listen: false)
            .fetchLocationListApi();
      },
    );
  }

  Widget _buildLocationList(GetLocationListViewModel locationViewModel, double screenWidth, double screenHeight) {
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
  }

  Widget _buildLocationItemCard(dynamic locationData, double screenWidth, double screenHeight) {
    final fullAddress = locationData.fullAddress ?? 'Unknown Address';
    final coordinates = locationData.geoLocation?.coordinates ?? [];
    final createdAt = locationData.createdAt;
    final locationType = locationData.type ?? 'DELIVERY_ADDRESS';
    final locationId = locationData.id ?? '';

    final isSelected = _controller.selectedLocationId == locationId;

    return GestureDetector(
      onTap: () => _controller.selectLocation(locationId, locationData),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(screenHeight * 0.015),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.button(context).withOpacity(0.05) : AppColors.containerBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 1, color: isSelected ? AppColors.button(context) : AppColors.border(context)),
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
                SizedBox(),
                if (createdAt != null)
                  Text(
                    _controller.formatDateTime(createdAt),
                    style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionButtons(double screenWidth) {
    return Positioned(
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
            // Delete Button
            GestureDetector(
              onTap: _controller.isDeleting ? null : _controller.deleteSelectedLocation,
              child: Container(
                width: screenWidth * 0.4,
                height: 42,
                decoration: BoxDecoration(color: AppColors.darkRedColor, borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: _controller.isDeleting
                      ? Container(height: 15, width: 50, child: LoadingAnimationWidget.progressiveDots(color: AppColors.whiteColor, size: 45))
                      : Text(
                          "Delete",
                          style: AppTextStyles.textSize14(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                        ),
                ),
              ),
            ),

            // Update Button
            GestureDetector(
              onTap: _controller.isUpdating ? null : _controller.updateSelectedLocation,
              child: Container(
                width: screenWidth * 0.4,
                height: 42,
                decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: _controller.isUpdating
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
    );
  }
}
