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
  // Store data properties (existing)
  Map<String, dynamic>? storeData;
  Map<String, dynamic>? retailer;
  double? distance;
  String? address;
  String? businessName;
  String? businessType;
  String? selectedStoreType;
  String? userID;

  // Controllers and state (existing)
  final TextEditingController notesController = TextEditingController();
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
      retailer = arguments['retailer'];
      distance = arguments['distance'];
      address = arguments['address'];
      businessName = arguments['businessName'];
      businessType = arguments['businessType'];
      selectedStoreType = arguments['selectedStoreType'];
      userID = arguments['userID'];
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
      RoutesName.checkoutScreen,
      arguments: {
        'storeData': storeData,
        'businessName': businessName,
        'businessType': businessType,
        'retailer': retailer,
        'distance': distance,
        'address': address,
        'selectedStoreType': selectedStoreType,
        'orderType': orderType,
        'orderItems': orderItems, // Manual entry items
        'uploadedPhotos': uploadedPhotos, // Photo items
        'voiceRecordingPath': voiceRecordingPath, // Voice recording
        'notes': notesController.text.trim(),
        // Summary counts
        'manualItemCount': orderItems.length,
        'photoCount': uploadedPhotos.length,
        'hasVoiceRecording': hasVoiceRecording,
        'userID': userID,
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
                if (businessName != null) _buildStoreInfoCard(),
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
        Icon(Icons.shopping_cart, color: AppColors.textPrimary(context), size: 20),
        SizedboxSpaccing.width02(context),
        Text(
          businessName ?? 'Store Name',
          style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildAvailabilityBadge(double screenHeight) {
    return Container(
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green),
          SizedboxSpaccing.width02(context),
          Text(
            "Available",
            style: AppTextStyles.textSize14(context, color: Colors.green, weight: FontWeight.w400),
          ),
        ],
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
            children: [_buildTab("Manual Entry", 0, FontAwesomeIcons.edit), _buildTab("Photo Upload", 1, FontAwesomeIcons.camera), _buildTab("Voice List", 2, Icons.mic)],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return ManualEntryTab(orderItems: orderItems, onAddItem: _addOrderItem, onRemoveItem: _removeOrderItem, notesController: notesController);
      case 1:
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

  Widget _buildProceedButton() {
    return GestureDetector(
      onTap: _proceedToCheckout,
      child: Container(
        height: 42,
        decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(4)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart, size: 18, color: Colors.white),
            SizedboxSpaccing.width01(context),
            Text(
              "Proceed",
              style: AppTextStyles.textSize12(context, color: Colors.white, weight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
}
