// import 'package:dinmajur_customer/configs/buttons/round_button.dart';
// import 'package:dinmajur_customer/configs/res/color.dart';
// import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
// import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
// import 'package:dinmajur_customer/configs/res/text_styles.dart';
// import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
// import 'package:dinmajur_customer/configs/utils/utils.dart';
// import 'package:dinmajur_customer/configs/widgets/customtext_with_formfield.dart';
// import 'package:dinmajur_customer/configs/widgets/dropdown/dynamic_dropdown.dart';
// import 'package:dinmajur_customer/data/response/status.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/get_locationlist_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
//
// class AddLocationScreenWidget extends StatefulWidget {
//   const AddLocationScreenWidget({super.key});
//
//   @override
//   State<AddLocationScreenWidget> createState() => _AddLocationScreenWidgetState();
// }
//
// class _AddLocationScreenWidgetState extends State<AddLocationScreenWidget> {
//   final TextEditingController _addressController = TextEditingController();
//   String _selectedCity = 'Chittagong';
//   String? _selectedLocationId;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<GetLocationListViewModel>().fetchLocationListApi();
//     });
//   }
//
//   @override
//   void dispose() {
//     _addressController.dispose();
//     super.dispose();
//   }
//
//   bool _isChittagongAddress(dynamic locationData) {
//     final fullAddress = (locationData.fullAddress ?? '').toLowerCase();
//     return fullAddress.contains('chittagong') || fullAddress.contains('chattogram') || fullAddress.contains('ctg');
//   }
//
//   String _formatDateTime(String? dateTimeStr) {
//     if (dateTimeStr == null) return '';
//     try {
//       final dateTime = DateTime.parse(dateTimeStr);
//       return DateFormat('MMM dd, yyyy').format(dateTime);
//     } catch (e) {
//       return '';
//     }
//   }
//
//   void _handleSaveAndContinue() {
//     if (_addressController.text.trim().isEmpty && _selectedLocationId == null) {
// Utils.flushBarErrorMessage("Please write an address or select a saved address", context);
// return;
//     }
//
//     // TODO: Implement save logic here
//     // You can access:
//     // - _selectedCity (always 'Chittagong')
//     // - _addressController.text (new address if entered)
//     // - _selectedLocationId (selected saved address ID)
//
//     print('Selected City: $_selectedCity');
//     print('New Address: ${_addressController.text}');
//     print('Selected Location ID: $_selectedLocationId');
//
//     Navigator.pop(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.containerBackground(context),
//       body: SafeArea(
//         child: ResPonsiveUi(mobile: _buildBody(), desktop: _buildBody(), tablet: _buildBody()),
//       ),
//     );
//   }
//
//   Widget _buildBody() {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Column(
//       children: [
//         _buildHeader(),
//         Expanded(
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 SizedboxSpaccing.height025(context),
//                 _buildWriteAddressSection(screenWidth),
//                 SizedboxSpaccing.height03(context),
//                 _buildSavedAddressSection(screenWidth, screenHeight),
//                 SizedboxSpaccing.height03(context),
//               ],
//             ),
//           ),
//         ),
//         _buildBottomButton(screenWidth, screenHeight),
//       ],
//     );
//   }
//
//   Widget _buildHeader() {
//     return GestureDetector(onTap: () => Navigator.pop(context), child: AppBarHeader("Delivery Address"));
//   }
//
//   Widget _buildWriteAddressSection(double screenWidth) {
//     return Container(
//       width: screenWidth * 0.9,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Write Address",
//             style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
//           ),
//           SizedboxSpaccing.height01(context),
//           Divider(height: 1,color: AppColors.border(context),),
//           SizedboxSpaccing.height015(context),
//
//           // City Dropdown
//           DynamicDropdown(
//             items: [
//               'Chittagong',
//               // 'Dhaka', 'Sylhet', 'Rajshahi', 'Khulna', 'Barishal', 'Rangpur', 'Mymensingh'
//             ],
//             selectedItem: _selectedCity,
//             onChanged: (String? newValue) {
//               if (newValue != null) {
//                 setState(() {
//                   _selectedCity = newValue;
//                 });
//               }
//             },
//             // titleText: "Select City",
//             titleStyle: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
//             hintText: "Choose your city",
//             height: 50,
//             width: screenWidth * 0.9,
//             borderRadius: 8,
//             backgroundColor: AppColors.containerBackground(context),
//             borderColor: AppColors.border(context),
//             dropdownBackgroundColor: AppColors.containerBackground(context),
//             selectedTextStyle: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context)),
//             itemTextStyle: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context)),
//           ),
//           SizedboxSpaccing.height015(context),
//           CustomTextFieldWithFormField(
//             placeholder: 'Write your address',
//             controller: _addressController,
//             height: 50,
//             width: MediaQuery.of(context).size.width * 0.9,
//             borderRadius: 8,
//             titleSpacing: 8,
//             backgroundColor: AppColors.containerBackground(context),
//
//             // Text Styles
//             titleTextStyle: AppTextStyles.textSize16(context, weight: FontWeight.w500),
//             inputTextStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400),
//             hintTextStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
//             onChanged: (value) {
//               if (value.isNotEmpty && _selectedLocationId != null) {
//                 setState(() {
//                   _selectedLocationId = null; // Clear selected location when user types
//                 });
//               }
//             },
//           )
//
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSavedAddressSection(double screenWidth, double screenHeight) {
//     return Column(
//       children: [
//         Container(
//           width: screenWidth * 0.9,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Saved Address",
//                 style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
//               ),
//               SizedboxSpaccing.height01(context),
//               Divider(height: 1,color: AppColors.border(context),),
//               SizedboxSpaccing.height005(context),
//             ],
//           ),
//         ),
//         SizedboxSpaccing.height015(context),
//         Consumer<GetLocationListViewModel>(
//           builder: (context, locationViewModel, child) {
//             return Container(
//               width: screenWidth * 0.9,
//               child: switch (locationViewModel.locationListData.status) {
//                 Status.LOADING => _buildLoadingState(),
//                 Status.ERROR => _buildErrorState(locationViewModel),
//                 Status.COMPLETED => _buildLocationList(locationViewModel, screenWidth, screenHeight),
//                 _ => Container(),
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Container(
//       height: 120,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(width: 1, color: AppColors.border(context)),
//       ),
//       child: Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45)),
//     );
//   }
//
//   Widget _buildErrorState(GetLocationListViewModel viewModel) {
//     return Container(
//       height: 120,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(width: 1, color: AppColors.border(context)),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, color: Colors.red, size: 24),
//             SizedBox(height: 8),
//             Text('Failed to load locations', style: AppTextStyles.textSize14(context, color: Colors.red)),
//             SizedBox(height: 8),
//             TextButton(
//               onPressed: () => viewModel.fetchLocationListApi(),
//               child: Text('Retry', style: TextStyle(color: AppColors.button(context))),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLocationList(GetLocationListViewModel locationViewModel, double screenWidth, double screenHeight) {
//     final locationList = locationViewModel.locationListData.data?.data ?? [];
//
//     if (locationList.isEmpty) {
//       return Container(
//         width: screenWidth * 0.9,
//         height: 120,
//         decoration: BoxDecoration(
//           color: AppColors.textFieldFill(context),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(width: 1, color: AppColors.border(context)),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(FontAwesomeIcons.mapLocationDot, size: 32, color: AppColors.subtitle(context).withOpacity(0.5)),
//               SizedBox(height: 8),
//               Text(
//                 "No Saved Locations",
//                 style: AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.subtitle(context)),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       itemCount: locationList.length,
//       itemBuilder: (context, index) {
//         return Container(
//           margin: EdgeInsets.only(bottom: index < locationList.length - 1 ? screenHeight * 0.015 : 0),
//           child: _buildLocationItemCard(locationList[index], screenWidth, screenHeight),
//         );
//       },
//     );
//   }
//
//   Widget _buildLocationItemCard(dynamic locationData, double screenWidth, double screenHeight) {
//     final fullAddress = locationData.fullAddress ?? 'Unknown Address';
//     final createdAt = locationData.createdAt;
//     final locationType = locationData.type ?? 'DELIVERY_ADDRESS';
//     final locationId = locationData.id ?? '';
//
//
//     final isChittagong = _isChittagongAddress(locationData);
//     final isSelected = _selectedLocationId == locationId && isChittagong;
//
//     return GestureDetector(
//       onTap: () {
//         if (isChittagong) {
//           setState(() {
//             _selectedLocationId = locationId;
//             _addressController.clear(); // Clear written address when selecting saved one
//           });
//         } else {
// Utils.flushBarErrorMessage("Only Chittagong addresses can be selected", context);
//         }
//       },
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         padding: EdgeInsets.all(screenHeight * 0.015),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppColors.containerBackground(context)
//               : isChittagong
//               ? AppColors.containerBackground(context)
//               : AppColors.textFieldFill(context).withOpacity(0.5),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             width: 1,
//             color: isSelected
//                 ? AppColors.button(context)
//                 : isChittagong
//                 ? AppColors.border(context)
//                 : AppColors.border(context).withOpacity(0.3),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   height: 40,
//                   width: 40,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     color: isSelected
//                         ? AppColors.button(context).withOpacity(0.1)
//                         : isChittagong
//                         ? AppColors.textFieldFill(context)
//                         : AppColors.subtitle(context).withOpacity(0.1),
//                   ),
//                   child: Center(child: Icon(FontAwesomeIcons.mapLocationDot, size: 20, color: isChittagong ? AppColors.darkRedColor.withOpacity(0.7) : AppColors.subtitle(context).withOpacity(0.5))),
//                 ),
//                 SizedboxSpaccing.width03(context),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               locationType.replaceAll('_', ' '),
//                               style: AppTextStyles.textSize14(context, weight: FontWeight.w600, color: isChittagong ? AppColors.textPrimary(context) : AppColors.subtitle(context)),
//                             ),
//                           ),
//                           if (!isChittagong)
//                             Text(
//                               'Not Available',
//                               style: AppTextStyles.textSize10(context, color: Colors.orange, weight: FontWeight.w400),
//                             )
//                         ],
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         fullAddress,
//                         style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: isChittagong ? AppColors.subtitle(context) : AppColors.subtitle(context).withOpacity(0.6)),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (isSelected)
//                   Container(
//                     padding: EdgeInsets.all(4),
//                     decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
//                     child: Icon(Icons.check, color: AppColors.whiteColor, size: 16),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomButton(double screenWidth, double screenHeight) {
//     return Container(
//       width: screenWidth,
//       padding: EdgeInsets.symmetric(
//           vertical: screenHeight * 0.02
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.containerBackground(context),
//       ),
//       child: Center( // Center the button
//         child: RoundButtonFlexible(
//           title: 'Save and Continue',
//           onPress: _handleSaveAndContinue,
//           height: 50,
//           width: screenWidth * 0.6,
//           borderRadius: 8,
//           backgroundColor: AppColors.textFieldFill(context),
//           borderColor: AppColors.border(context),
//           showLeftIcon: false,
//           showRightIcon: false,
//           textStyle: AppTextStyles.textSize16(
//             context,
//             weight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/widgets/customtext_with_formfield.dart';
import 'package:dinmajur_customer/configs/widgets/dropdown/dynamic_dropdown.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view_model/homeview_model/location_view_model/get_locationlist_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddLocationScreenWidget extends StatefulWidget {
  const AddLocationScreenWidget({super.key});

  @override
  State<AddLocationScreenWidget> createState() => _AddLocationScreenWidgetState();
}

class _AddLocationScreenWidgetState extends State<AddLocationScreenWidget> {
  final TextEditingController _addressController = TextEditingController();
  String _selectedCity = 'Chittagong';
  String? _selectedLocationId;
  dynamic _selectedLocationData; // ✅ Store complete location data

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

  bool _isChittagongAddress(dynamic locationData) {
    final fullAddress = (locationData.fullAddress ?? '').toLowerCase();
    return fullAddress.contains('chittagong') || fullAddress.contains('chattogram') || fullAddress.contains('ctg');
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  // ✅ Handle Save and Continue - Return selected address data
  void _handleSaveAndContinue() {
    if (_addressController.text.trim().isEmpty && _selectedLocationId == null) {
      Utils.flushBarErrorMessage("Please write an address or select a saved address", context);
      return;
    }

    // ✅ Prepare data to return to checkout screen
    Map<String, dynamic> selectedAddressData = {};

    if (_selectedLocationId != null && _selectedLocationData != null) {
      // ✅ User selected a saved address
      selectedAddressData = {
        'addressType': 'saved',
        'locationId': _selectedLocationId,
        'fullAddress': _selectedLocationData.fullAddress ?? '',
        'city': _selectedCity,
        'coordinates': _selectedLocationData.geoLocation?.coordinates ?? [],
      };

      print('✅ Selected Saved Address:');
      print('   - Location ID: $_selectedLocationId');
      print('   - Full Address: ${_selectedLocationData.fullAddress}');
      print('   - City: $_selectedCity');
    } else if (_addressController.text.trim().isNotEmpty) {
      // ✅ User typed a new address
      selectedAddressData = {
        'addressType': 'new',
        'locationId': null,
        'fullAddress': _addressController.text.trim(),
        'city': _selectedCity,
        'coordinates': [],
      };

      print('✅ New Address Entered:');
      print('   - Full Address: ${_addressController.text.trim()}');
      print('   - City: $_selectedCity');
    }

    // ✅ Return data to previous screen
    Navigator.pop(context, selectedAddressData);
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
    return GestureDetector(onTap: () => Navigator.pop(context), child: AppBarHeader("Delivery Address"));
  }

  Widget _buildWriteAddressSection(double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Write Address",
            style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
          ),
          SizedboxSpaccing.height01(context),
          Divider(height: 1, color: AppColors.border(context)),
          SizedboxSpaccing.height015(context),

          // City Dropdown
          DynamicDropdown(
            items: ['Chittagong'],
            selectedItem: _selectedCity,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCity = newValue;
                });
              }
            },
            titleStyle: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
            hintText: "Choose your city",
            height: 50,
            width: screenWidth * 0.9,
            borderRadius: 8,
            backgroundColor: AppColors.containerBackground(context),
            borderColor: AppColors.border(context),
            dropdownBackgroundColor: AppColors.containerBackground(context),
            selectedTextStyle: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context)),
            itemTextStyle: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context)),
          ),
          SizedboxSpaccing.height015(context),
          CustomTextFieldWithFormField(
            placeholder: 'Write your address',
            controller: _addressController,
            height: 50,
            width: MediaQuery.of(context).size.width * 0.9,
            borderRadius: 8,
            titleSpacing: 8,
            backgroundColor: AppColors.containerBackground(context),
            titleTextStyle: AppTextStyles.textSize16(context, weight: FontWeight.w500),
            inputTextStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400),
            hintTextStyle: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
            onChanged: (value) {
              if (value.isNotEmpty && _selectedLocationId != null) {
                setState(() {
                  _selectedLocationId = null;
                  _selectedLocationData = null; // ✅ Clear saved location data
                });
              }
            },
          )
        ],
      ),
    );
  }

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
                style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
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
                Status.LOADING => _buildLoadingState(),
                Status.ERROR => _buildErrorState(locationViewModel),
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
      child: Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45)),
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
            Text('Failed to load locations', style: AppTextStyles.textSize14(context, color: Colors.red)),
            SizedBox(height: 8),
            TextButton(
              onPressed: () => viewModel.fetchLocationListApi(),
              child: Text('Retry', style: TextStyle(color: AppColors.button(context))),
            ),
          ],
        ),
      ),
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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1, color: AppColors.border(context)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.mapLocationDot, size: 32, color: AppColors.subtitle(context).withOpacity(0.5)),
              SizedBox(height: 8),
              Text(
                "No Saved Locations",
                style: AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.subtitle(context)),
              ),
            ],
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
    final createdAt = locationData.createdAt;
    final locationType = locationData.type ?? 'DELIVERY_ADDRESS';
    final locationId = locationData.id ?? '';

    final isChittagong = _isChittagongAddress(locationData);
    final isSelected = _selectedLocationId == locationId && isChittagong;

    return GestureDetector(
      onTap: () {
        if (isChittagong) {
          setState(() {
            _selectedLocationId = locationId;
            _selectedLocationData = locationData; // ✅ Store complete location data
            _addressController.clear(); // Clear written address when selecting saved one
          });
        } else {
          Utils.flushBarErrorMessage("Only Chittagong addresses can be selected", context);
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(screenHeight * 0.015),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.containerBackground(context)
              : isChittagong
              ? AppColors.containerBackground(context)
              : AppColors.textFieldFill(context).withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 1,
            color: isSelected
                ? AppColors.button(context)
                : isChittagong
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
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected
                        ? AppColors.button(context).withOpacity(0.1)
                        : isChittagong
                        ? AppColors.textFieldFill(context)
                        : AppColors.subtitle(context).withOpacity(0.1),
                  ),
                  child: Center(
                    child: Icon(
                      FontAwesomeIcons.mapLocationDot,
                      size: 20,
                      color: isChittagong ? AppColors.darkRedColor.withOpacity(0.7) : AppColors.subtitle(context).withOpacity(0.5),
                    ),
                  ),
                ),
                SizedboxSpaccing.width03(context),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              locationType.replaceAll('_', ' '),
                              style: AppTextStyles.textSize14(
                                context,
                                weight: FontWeight.w600,
                                color: isChittagong ? AppColors.textPrimary(context) : AppColors.subtitle(context),
                              ),
                            ),
                          ),
                          if (!isChittagong)
                            Text(
                              'Not Available',
                              style: AppTextStyles.textSize10(context, color: Colors.orange, weight: FontWeight.w400),
                            )
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        fullAddress,
                        style: AppTextStyles.textSize12(
                          context,
                          weight: FontWeight.w400,
                          color: isChittagong ? AppColors.subtitle(context) : AppColors.subtitle(context).withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
                    child: Icon(Icons.check, color: AppColors.whiteColor, size: 16),
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
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
      ),
      child: Center(
        child: RoundButtonFlexible(
          title: 'Save and Continue',
          onPress: _handleSaveAndContinue,
          height: 50,
          width: screenWidth * 0.6,
          borderRadius: 8,
          backgroundColor: AppColors.textFieldFill(context),
          borderColor: AppColors.border(context),
          showLeftIcon: false,
          showRightIcon: false,
          textStyle: AppTextStyles.textSize16(
            context,
            weight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}