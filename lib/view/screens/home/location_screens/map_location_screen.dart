// map_location_screen.dart
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/view/screens/home/location_screens/controller/map_locationscreen_controller.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/newlocation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MapLocationScreen extends StatefulWidget {
  const MapLocationScreen({super.key});

  @override
  State<MapLocationScreen> createState() => _MapLocationScreenState();
}

class _MapLocationScreenState extends State<MapLocationScreen> {
  late MapLocationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize controller with context and setState
    _controller = MapLocationController(context, setState);

    // Call initialize after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initialize();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.setMapStyle();
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

    return Column(children: [SizedboxSpaccing.height005(context), _buildSearchBar(screenWidth), SizedboxSpaccing.height005(context), _buildMap()]);
  }

  Widget _buildSearchBar(double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(height: 20, width: 24, alignment: Alignment.centerLeft, child: SvgPicture.asset("assets/images/header_arrow.svg")),
          ),

          // Search field
          Container(
            width: screenWidth * 0.7,
            child: GooglePlaceAutoCompleteTextField(
              textEditingController: _controller.addressController,
              googleAPIKey: _controller.googlePlacesApiKey,
              isCrossBtnShown: false,
              inputDecoration: InputDecoration(
                hintText: 'Search for a location...',
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
              countries: ["bd"],
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: _controller.onPlaceSelected,
              itemClick: (Prediction prediction) {
                _controller.addressController.text = prediction.description!;
                _controller.onPlaceSelected(prediction);
              },
              seperatedBuilder: Divider(color: AppColors.border(context), height: 1),
              containerHorizontalPadding: 5,
              itemBuilder: (context, index, Prediction prediction) {
                return _buildPlaceItem(prediction);
              },
            ),
          ),

          // Clear button
          GestureDetector(
            onTap: _controller.clearSelection,
            child: Container(height: 20, width: 24, alignment: Alignment.centerLeft, child: Icon(FontAwesomeIcons.x, size: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Expanded(
      child: Stack(
        children: [
          // Google Map
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: MapLocationController.kGooglePlex,
            onMapCreated: _controller.onMapCreated,
            onTap: _controller.onMapTap,
            markers: _controller.markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
          ),

          // Current location button
          _buildCurrentLocationButton(),

          // Location info card
          if (_controller.selectedLocation != null) _buildLocationInfoCard(),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: AppColors.button(context),
        onPressed: _controller.isLoadingCurrentLocation ? null : _controller.getCurrentLocation,
        child: _controller.isLoadingCurrentLocation
            ? LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 20)
            : Icon(FontAwesomeIcons.locationCrosshairs, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildLocationInfoCard() {
    return Positioned(
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
              // Header
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

              // Address
              Text(
                _controller.selectedAddress.isNotEmpty ? _controller.selectedAddress : 'Getting address...',
                style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),

              // Coordinates
              Text(
                'Lat: ${_controller.selectedLocation!.latitude.toStringAsFixed(6)}, '
                'Lng: ${_controller.selectedLocation!.longitude.toStringAsFixed(6)}',
                style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context).withOpacity(0.7)),
              ),
              SizedBox(height: 12),

              // Confirm button
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Consumer<AddLocationViewModel>(
      builder: (context, addLocationProvider, child) {
        final isLoading = addLocationProvider.createAddLocationLoading || _controller.isLoadingAddress;

        return SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed: isLoading ? null : _controller.confirmLocation,
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
    );
  }

  Widget _buildPlaceItem(Prediction prediction) {
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
  }
}
