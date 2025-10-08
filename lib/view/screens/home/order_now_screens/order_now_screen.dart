import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/custom_appbar.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/view/screens/home/order_now_screens/build_tabs/manual_entry_tab.dart';
import 'package:dinmajur_customer/view/screens/home/order_now_screens/build_tabs/photo_upload_tab.dart';
import 'package:dinmajur_customer/view/screens/home/order_now_screens/build_tabs/voice_list_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderNow extends StatefulWidget {
  const OrderNow({super.key});

  @override
  State<OrderNow> createState() => _OrderNowState();
}

class _OrderNowState extends State<OrderNow> {
  // Store data properties
  Map<String, dynamic>? storeData;
  String? store_distance;
  String? store_address;
  String? store_businessName;
  String? store_status;
  String? store_businessType;
  String? selectedStoreType;
  String? store_userID;
  String? store_FullAddress;
  String? store_logoUrl;
  double? storeLatitude;
  double? storeLongitude;

  // Customer location
  String? customerFullAddress;
  double? customerLongitude;
  double? customerLatitude;

  /// Controllers  For manual entry tab
  final TextEditingController notesController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  String? selectedDeliveryTime;

  List<Map<String, dynamic>> orderItems = [];
  int _selectedTabIndex = 0;

  // ADD THESE NEW PROPERTIES:
  List<Map<String, dynamic>> uploadedPhotos = [];
  String? voiceRecordingPath;
  String? voiceRecordingDuration;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadArguments();
  }

  void _loadArguments() {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      storeData = arguments['storeData'];
      store_distance = arguments['distanceText'];
      store_businessName = arguments['businessName'];
      store_status = arguments['status'];
      store_businessType = arguments['businessType'];
      selectedStoreType = arguments['selectedStoreType'];
      store_userID = arguments['userID'];
      store_FullAddress = arguments['storeFullAddress'];
      storeLatitude = arguments['storeLatitude'];
      storeLongitude = arguments['storeLongitude'];
      store_logoUrl = arguments['logoUrl'];

      // Customer/User location data
      customerFullAddress = arguments['customerFullAddress'];
      customerLongitude = arguments['customerLongitude'];
      customerLatitude = arguments['customerLatitude'];
    }
  }
  void _addOrderItem(Map<String, dynamic> item) {
    setState(() {
      orderItems.add(item);
    });
  }

  void _removeOrderItem(int index) {
    setState(() {
      orderItems.removeAt(index);
    });
  }
  void _proceedToCheckout() {
    // Validation for manual entry tab
    if (_selectedTabIndex == 0) {
      // Check budget
      if (budgetController.text.trim().isEmpty) {
        Utils.flushBarErrorMessage("Please enter your budget before proceeding", context);
        return;
      }

      // Check if at least one item is added
      if (orderItems.isEmpty) {
        Utils.flushBarErrorMessage("Please add at least one item to your order", context);
        return;
      }

      // Check if delivery time is selected
      if (selectedDeliveryTime == null) {
        Utils.flushBarErrorMessage("Please select a delivery time", context);
        return;
      }
    }

    // Check if user has added any content from any tab
    bool hasManualItems = orderItems.isNotEmpty;
    bool hasPhotos = uploadedPhotos.isNotEmpty;
    bool hasVoiceRecording = voiceRecordingPath != null && voiceRecordingPath!.isNotEmpty;

    // Require at least one type of content
    if (!hasManualItems && !hasPhotos && !hasVoiceRecording) {
      Utils.flushBarErrorMessage("Please add at least one item, photo, or voice recording to proceed", context);
      return;
    }

    // Determine primary order type based on what user has added most
    String orderType = 'mixed';
    if (hasManualItems && !hasPhotos && !hasVoiceRecording) {
      orderType = 'manual';
    } else if (!hasManualItems && hasPhotos && !hasVoiceRecording) {
      orderType = 'photo';
    } else if (!hasManualItems && !hasPhotos && hasVoiceRecording) {
      orderType = 'voice';
    }

    // Navigate to checkout screen with all data
    Navigator.pushNamed(
      context,
      RoutesName.checkoutScreenNew,
      arguments: {
        'storeData': storeData,
        'businessName': store_businessName,
        'status': store_status,
        'businessType': store_businessType,
        'distanceText': store_distance,
        'address': store_FullAddress,
        'logoUrl': store_logoUrl,
        'selectedStoreType': selectedStoreType,
        'orderType': orderType,
        'orderItems': orderItems,
        'uploadedPhotos': uploadedPhotos,
        'voiceRecordingPath': voiceRecordingPath,
        'notes': notesController.text.trim(),
        'budget': budgetController.text.trim(),
        'deliveryTime': selectedDeliveryTime,
        'manualItemCount': orderItems.length,
        'photoCount': uploadedPhotos.length,
        'hasVoiceRecording': hasVoiceRecording,
        'userID': store_userID,
        'storeLatitude': storeLatitude, // ADD THIS
        'storeLongitude': storeLongitude, // ADD THIS

        // Customer location data
        'customerFullAddress': customerFullAddress,
        'customerLongitude': customerLongitude,
        'customerLatitude': customerLatitude,
      },
    );
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
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedboxSpaccing.height02(context),
                if ( store_businessName != null) _buildStoreInfoCard(),
                SizedboxSpaccing.height02(context),
                Container(
                  width: screenWidth*0.9,
                  decoration: BoxDecoration(
                    color: AppColors.containerBackground(context),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(width: 1, color: AppColors.border(context)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: screenWidth*0.9,
                        padding: EdgeInsets.only(left:screenHeight * 0.02,top:screenHeight * 0.015 ,bottom:screenHeight * 0.015 ),
                        decoration:  BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          border: Border(
                            bottom: BorderSide(
                              width: 1,
                              color: AppColors.border(context),
                            )
                          )
                        ),
                        child:Text(
                            'Set Budget',
                            style: AppTextStyles.textSize18(context, weight: FontWeight.w500)
                        ),
                      ),
                      Padding(
                        padding:  EdgeInsets.all(screenHeight * 0.02),
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.textFieldFill(context),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              width: 1,
                              color: AppColors.border(context),
                            ),
                          ),
                          child: TextFormField(
                            controller: budgetController,
                            keyboardType: TextInputType.number,
                            style: AppTextStyles.textSize16(context, weight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: "e.g., 1500",
                              hintStyle: AppTextStyles.textSize16(context, color: AppColors.hintColor(context), weight: FontWeight.w400),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedboxSpaccing.height02(context),
                _buildTabSection(),
                SizedboxSpaccing.height02(context),
                _buildActionButtons(),
                SizedboxSpaccing.height04(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: const CustomAppBar(appBarTitle: "New Order"),
    );
  }

  Widget _buildStoreInfoCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02, vertical: screenHeight * 0.015),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildStoreInfo(), _buildAvailabilityBadge(screenHeight)]),
    );
  }

  Widget _buildStoreInfo() {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          margin: EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: store_logoUrl != null && store_logoUrl!.isNotEmpty
                ? Colors.transparent
                : AppColors.textPrimary(context),
            borderRadius: BorderRadius.circular(6),
            image: store_logoUrl != null && store_logoUrl!.isNotEmpty
                ? DecorationImage(
              image: NetworkImage(store_logoUrl!),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: store_logoUrl == null || store_logoUrl!.isEmpty
              ? Icon(
            Icons.local_grocery_store,
            color: AppColors.textPrimary(context),
            size: 20,
          )
              : null,
        ),
        SizedboxSpaccing.width02(context),
        Text(
          store_businessName ?? 'Store Name',
          style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildAvailabilityBadge(double screenHeight) {
    return         Container(
      height: 24,
      width: 75,
      decoration: BoxDecoration(
        color: store_status=="Available"? AppColors.oceanGreenColor : AppColors.darkRedColor,
        borderRadius: BorderRadius.circular(100),),
      child: Center(
        child: Text( store_status!,
          style: AppTextStyles.textSize10(context, color: AppColors.whiteColor, weight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      // padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        // borderRadius: BorderRadius.circular(24),
        // border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(children: [_buildTabHeaders(screenWidth), _buildTabContent()]),
    );
  }

  Widget _buildTab(String title, int index, IconData icon) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          // margin: EdgeInsets.all(screenWidth * 0.005),
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.012),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.containerBackground(context) : Colors.transparent,
            border: isSelected ? Border.all(color: AppColors.border(context), width: 1) : Border.all(color: Colors.transparent, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: screenWidth * 0.035, // Responsive icon size
                color: isSelected ? AppColors.button(context) : AppColors.textPrimary(context),
              ),
              SizedBox(width: screenWidth * 0.01), // Responsive spacing
              Expanded(
                // Changed from Flexible to Expanded
                child: Text(
                  title,
                  style: AppTextStyles.textSize12(context, weight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppColors.button(context) : AppColors.textPrimary(context)),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false, // Prevents text wrapping
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Also update the _buildTabHeaders method for better responsiveness
  Widget _buildTabHeaders(double screenWidth) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(left: screenHeight * 0.02, right: screenHeight * 0.02, top: screenHeight * 0.02),
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        border: Border(
          left: BorderSide(width: 1, color: AppColors.border(context)),
          right: BorderSide(width: 1, color: AppColors.border(context)),
          top: BorderSide(width: 1, color: AppColors.border(context)),
          bottom: BorderSide.none,
        ),
        borderRadius: BorderRadius.only(topRight: Radius.circular(24), topLeft: Radius.circular(24)),
      ),
      child: Center(
        child: Container(
          width: screenWidth * 0.9,
          decoration: BoxDecoration(
            color: AppColors.textFieldFill(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_buildTab("Manual", 0, FontAwesomeIcons.edit), _buildTab("Upload", 1, FontAwesomeIcons.camera), _buildTab("Voice", 2, Icons.mic)],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return ManualEntryTab(
          orderItems: orderItems,
          onAddItem: _addOrderItem,
          onRemoveItem: _removeOrderItem,
          notesController: notesController,
          budgetController: budgetController,
          initialDeliveryTime: selectedDeliveryTime,
          onDeliveryTimeSelected: (time) {
            setState(() {
              selectedDeliveryTime = time;
            });
          },
        );      case 1:
        return PhotoUploadTab(
          initialPhotos: uploadedPhotos, // PASS EXISTING PHOTOS
          onPhotosChanged: (photos) {
            setState(() {
              uploadedPhotos = photos;
            });
          },
        );
      case 2:
        return VoiceListTab(
          initialRecordingPath: voiceRecordingPath, // PASS CURRENT RECORDING
          initialDuration: voiceRecordingDuration, // PASS CURRENT DURATION
          onRecordingChanged: (recordingPath) {
            setState(() {
              voiceRecordingPath = recordingPath;
              // You might also want to update duration here when you implement actual recording
              if (recordingPath != null) {
                voiceRecordingDuration = "01:23"; // Replace with actual duration
              } else {
                voiceRecordingDuration = null;
              }
            });
          },
        );
      default:
        return Container();
    }
  }

  Widget _buildActionButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      child: RoundButton(title: "Place Order", onPress: _proceedToCheckout, iconData: Icons.arrow_forward_ios_rounded),
    );
  }


  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
}
