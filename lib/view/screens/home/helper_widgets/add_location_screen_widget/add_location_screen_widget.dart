import 'dart:convert';
import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/google_place_search_textfield/google_place_search_textfield.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/dropdown/dynamic_dropdown.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/get_locationlist_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddLocationScreenWidget extends StatefulWidget {
  const AddLocationScreenWidget({super.key});

  @override
  State<AddLocationScreenWidget> createState() => _AddLocationScreenWidgetState();
}

class _AddLocationScreenWidgetState extends State<AddLocationScreenWidget> {
  final TextEditingController _addressController = TextEditingController();
  String _selectedCity = 'Chittagong';
  String? _selectedLocationId;
  dynamic _selectedLocationData;
  Map<String, dynamic>? _newAddressLocationData;


  Future<void> _handleSaveAndContinue() async {
    // ── Case 1: Nothing entered at all ───────────────────────────────
    if (_addressController.text.trim().isEmpty && _selectedLocationId == null) {
      Utils.flushBarErrorMessage(
          "Please  select a saved address", context);
      return;
    }

    // ── Case 2: User typed but never picked from suggestions ─────────
    // _newAddressLocationData is only set when onPlaceSelected fires.
    // If it's null but text is present → user typed without selecting.
    if (_selectedLocationId == null &&
        _addressController.text.trim().isNotEmpty &&
        _newAddressLocationData == null) {
      Utils.flushBarErrorMessage(
          "Please select an address from the suggestions", context);
      return;
    }

    Map<String, dynamic> selectedAddressData = {};

    if (_selectedLocationId != null && _selectedLocationData != null) {
      // ── Saved address selected from list ─────────────────────────
      selectedAddressData = {
        'addressType': 'saved',
        'fullAddress': _selectedLocationData.fullAddress ?? '',
        'location': {
          "fullAddress": _selectedLocationData.fullAddress ?? '',
          "country":     _selectedLocationData.country ?? '',
          "city":        _selectedLocationData.city ?? '',
          "geoLocation": {
            "type":        _selectedLocationData.geoLocation?.type ?? "Point",
            "coordinates": _selectedLocationData.geoLocation?.coordinates ?? [],
            "timestamp":   DateTime.now().toUtc().toIso8601String(),
          },
        },
      };
    } else {
      // ── Google Place selected (guaranteed by check above) ─────────
      selectedAddressData = {
        'addressType': 'new',
        'fullAddress': _addressController.text.trim(),
        'location': _newAddressLocationData!, // safe — null checked above
      };
    }

    // ✅ Save to global SharedPreferences session
    final locationData = selectedAddressData['location'] as Map<String, dynamic>?;
    final fullAddress  = selectedAddressData['fullAddress'] as String? ?? '';

    if (locationData != null && fullAddress.isNotEmpty) {
      await CheckoutSessionLocationService.save(
        locationData: locationData,
        fullAddress:  fullAddress,
      );
    }

    if (mounted) Navigator.pop(context, selectedAddressData);
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetLocationListViewModel>().fetchLocationListApi();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }


  bool _isServiceableAddress(dynamic locationData) {
    final city = (locationData.city ?? '').toLowerCase().trim();
    const serviceableCities = {
      'chittagong', 'chattogram', 'chottogram', 'chattagam', 'ctg',
      'চট্টগ্রাম', 'চিটাগাং',
      'dhaka', 'ঢাকা',
    };
    return serviceableCities.contains(city);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(
          mobile:  _buildBody(),
          desktop: _buildBody(),
          tablet:  _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final screenWidth  = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedboxSpaccing.height025(context),
                _buildWriteAddressSection(screenWidth),
                SizedboxSpaccing.height03(context),
                _buildSavedAddressSection(screenWidth, screenHeight),
                SizedboxSpaccing.height03(context),
              ],
            ),
          ),
        ),
        _buildBottomButton(screenWidth, screenHeight),
      ],
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: AppBarHeader("Delivery Address"),
    );
  }

  Widget _buildWriteAddressSection(double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Write Address",
            style: AppTextStyles.textSize18(context,
                weight: FontWeight.w500, color: AppColors.textPrimary(context)),
          ),
          SizedboxSpaccing.height01(context),
          Divider(height: 1, color: AppColors.border(context)),
          SizedboxSpaccing.height015(context),

          // City Dropdown
          // DynamicDropdown(
          //   items: ['Chittagong', 'Dhaka'],
          //   selectedItem: _selectedCity,
          //   onChanged: (String? newValue) {
          //     if (newValue != null) setState(() => _selectedCity = newValue);
          //   },
          //   titleStyle: AppTextStyles.textSize14(context,
          //       weight: FontWeight.w500, color: AppColors.textPrimary(context)),
          //   hintText: "Choose your city",
          //   height: 50,
          //   width: screenWidth * 0.9,
          //   borderRadius: 8,
          //   backgroundColor: AppColors.containerBackground(context),
          //   borderColor: AppColors.border(context),
          //   dropdownBackgroundColor: AppColors.containerBackground(context),
          //   selectedTextStyle: AppTextStyles.textSize14(context,
          //       color: AppColors.textPrimary(context)),
          //   itemTextStyle: AppTextStyles.textSize14(context,
          //       color: AppColors.textPrimary(context)),
          // ),
          // SizedboxSpaccing.height015(context),

          // Google Place Search
          GooglePlaceSearchTextField(
            placeholder: 'Search your address',
            controller: _addressController,
            height: 50,
            width: screenWidth * 0.9,
            backgroundColor: AppColors.containerBackground(context),
            borderColor: AppColors.border(context),
            inputTextStyle:
            AppTextStyles.textSize14(context, weight: FontWeight.w400),
            hintTextStyle: AppTextStyles.textSize14(context,
                weight: FontWeight.w400, color: AppColors.subtitle(context)),
            onPlaceSelected: (GooglePlaceSearchResult result) {
              setState(() {
                _newAddressLocationData = result.toLocationData();
                _selectedLocationId   = null; // clear saved selection
                _selectedLocationData = null;
              });
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Saved Address section
  // ─────────────────────────────────────────────────────────────

  Widget _buildSavedAddressSection(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Container(
          width: screenWidth * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Saved Address",
                style: AppTextStyles.textSize18(context,
                    weight: FontWeight.w500,
                    color: AppColors.textPrimary(context)),
              ),
              SizedboxSpaccing.height01(context),
              Divider(height: 1, color: AppColors.border(context)),
              SizedboxSpaccing.height005(context),
            ],
          ),
        ),
        SizedboxSpaccing.height015(context),
        Consumer<GetLocationListViewModel>(
          builder: (context, locationViewModel, child) {
            return Container(
              width: screenWidth * 0.9,
              child: switch (locationViewModel.locationListData.status) {
                Status.LOADING   => _buildLoadingState(),
                Status.ERROR     => _buildErrorState(locationViewModel),
                Status.COMPLETED =>
                    _buildLocationList(locationViewModel, screenWidth, screenHeight),
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
        child: LoadingAnimationWidget.progressiveDots(
            color: AppColors.button(context), size: 45),
      ),
    );
  }

  Widget _buildErrorState(GetLocationListViewModel viewModel) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24),
            SizedBox(height: 8),
            Text('Failed to load locations',
                style: AppTextStyles.textSize14(context, color: Colors.red)),
            SizedBox(height: 8),
            TextButton(
              onPressed: () => viewModel.fetchLocationListApi(),
              child: Text('Retry',
                  style: TextStyle(color: AppColors.button(context))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationList(GetLocationListViewModel locationViewModel,
      double screenWidth, double screenHeight) {
    final locationList =
        locationViewModel.locationListData.data?.data ?? [];

    if (locationList.isEmpty) {
      return Container(
        width: screenWidth * 0.9,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.textFieldFill(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1, color: AppColors.border(context)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.mapLocationDot,
                  size: 32,
                  color: AppColors.subtitle(context).withOpacity(0.5)),
              SizedBox(height: 8),
              Text(
                "No Saved Locations",
                style: AppTextStyles.textSize16(context,
                    weight: FontWeight.w500,
                    color: AppColors.subtitle(context)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: locationList.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(
              bottom: index < locationList.length - 1
                  ? screenHeight * 0.015
                  : 0),
          child: _buildLocationItemCard(
              locationList[index], screenWidth, screenHeight),
        );
      },
    );
  }

  Widget _buildLocationItemCard(
      dynamic locationData, double screenWidth, double screenHeight) {
    final fullAddress  = locationData.fullAddress ?? 'Unknown Address';
    final locationType = locationData.type ?? 'DELIVERY_ADDRESS';
    final locationId   = locationData.id ?? '';

    final isServiceable = _isServiceableAddress(locationData);
    final isSelected    = _selectedLocationId == locationId && isServiceable;

    return GestureDetector(
      onTap: () {
        if (isServiceable) {
          setState(() {
            _selectedLocationId   = locationId;
            _selectedLocationData = locationData;
            _addressController.clear();
            _newAddressLocationData = null;
          });
        } else {
          Utils.flushBarErrorMessage(
              "Only Chittagong addresses can be selected", context);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(screenHeight * 0.015),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.containerBackground(context)
              : isServiceable
              ? AppColors.containerBackground(context)
              : AppColors.textFieldFill(context).withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 1,
            color: isSelected
                ? AppColors.button(context)
                : isServiceable
                ? AppColors.border(context)
                : AppColors.border(context).withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon box
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected
                        ? AppColors.button(context).withOpacity(0.1)
                        : isServiceable
                        ? AppColors.textFieldFill(context)
                        : AppColors.subtitle(context).withOpacity(0.1),
                  ),
                  child: Center(
                    child: Icon(
                      FontAwesomeIcons.mapLocationDot,
                      size: 20,
                      color: isServiceable
                          ? AppColors.darkRedColor.withOpacity(0.7)
                          : AppColors.subtitle(context).withOpacity(0.5),
                    ),
                  ),
                ),
                SizedboxSpaccing.width03(context),
                // Address text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              locationType.replaceAll('_', ' ').toLowerCase().split(' ').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' '),
                              style: AppTextStyles.textSize14(
                                context,
                                weight: FontWeight.w600,
                                color: isServiceable
                                    ? AppColors.textPrimary(context)
                                    : AppColors.subtitle(context),
                              ),
                            ),
                          ),
                          if (!isServiceable)
                            Text(
                              'Not Available',
                              style: AppTextStyles.textSize10(context,
                                  color: Colors.orange,
                                  weight: FontWeight.w400),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fullAddress,
                        style: AppTextStyles.textSize12(
                          context,
                          weight: FontWeight.w400,
                          color: isServiceable
                              ? AppColors.subtitle(context)
                              : AppColors.subtitle(context).withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Check badge
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: AppColors.button(context),
                        shape: BoxShape.circle),
                    child: Icon(Icons.check,
                        color: AppColors.whiteColor, size: 16),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBottomButton(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth,
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      decoration: BoxDecoration(color: AppColors.containerBackground(context)),
      child: Center(
        child: RoundButtonFlexible(
          title: 'Save and Continue',
          onPress: _handleSaveAndContinue, // Future<void> — works fine
          height: 50,
          width: screenWidth * 0.6,
          borderRadius: 8,
          backgroundColor: AppColors.textFieldFill(context),
          borderColor: AppColors.border(context),
          showLeftIcon: false,
          showRightIcon: false,
          textStyle:
          AppTextStyles.textSize16(context, weight: FontWeight.w600),
        ),
      ),
    );
  }
}



/// Global session location service.
/// Used by ANY checkout screen (Beauty, HouseKeeper, Cooking, etc.)
/// to persist a temporary delivery address chosen during checkout.
///
/// Lifecycle:
///   • Saved  → when user picks address in AddLocationScreenWidget
///   • Read   → when any checkout screen resumes after address edit
///   • Cleared → when booking is confirmed OR user returns to Home (isFromHome: true)
class CheckoutSessionLocationService {
  static const String _locationKey = 'checkout_session_location';
  static const String _addressKey  = 'checkout_session_address';

  // ─────────────────────────────────────────────────────────────
  // WRITE
  // ─────────────────────────────────────────────────────────────

  /// Persist location data + address string to prefs.
  /// Called by AddLocationScreenWidget before Navigator.pop().
  static Future<void> save({
    required Map<String, dynamic> locationData,
    required String fullAddress,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_locationKey, jsonEncode(locationData));
      await prefs.setString(_addressKey,  fullAddress);
    } catch (e) {
    }
  }

  // ─────────────────────────────────────────────────────────────
  // READ
  // ─────────────────────────────────────────────────────────────

  /// Returns the saved location map, or null if nothing is stored.
  static Future<Map<String, dynamic>?> getLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_locationKey);
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Returns the saved full address string, or null if nothing is stored.
  static Future<String?> getAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_addressKey);
    } catch (e) {
      return null;
    }
  }

  /// Returns both location map and address together as a record.
  /// Convenience helper so callers do one await instead of two.
  static Future<({Map<String, dynamic>? location, String? address})> getAll() async {
    final location = await getLocation();
    final address  = await getAddress();
    return (location: location, address: address);
  }

  // ─────────────────────────────────────────────────────────────
  // CHECK
  // ─────────────────────────────────────────────────────────────

  static Future<bool> hasSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_locationKey);
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // CLEAR
  // ─────────────────────────────────────────────────────────────

  /// Clear session data.
  /// Call this:
  ///   1. On booking confirmed (any service)
  ///   2. On screen init when isFromHome == true
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_locationKey);
      await prefs.remove(_addressKey);
    } catch (e) {
    }
  }
}