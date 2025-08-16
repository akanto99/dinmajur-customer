import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/custom_appbar.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
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

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Draft saved successfully",
          style: AppTextStyles.textSize14(context),
        ),
        backgroundColor: AppColors.whiteColor,
      ),
    );
  }
  void _proceedToCheckout() {
    // Check if user has added any content from any tab
    bool hasManualItems = orderItems.isNotEmpty;
    bool hasPhotos = uploadedPhotos.isNotEmpty;
    bool hasVoiceRecording = voiceRecordingPath != null && voiceRecordingPath!.isNotEmpty;

    // Require at least one type of content
    if (!hasManualItems && !hasPhotos && !hasVoiceRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least one item, photo, or voice recording to proceed"),
          backgroundColor: Colors.red,
        ),
      );
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
      backgroundColor: AppColors.appBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(
          mobile: _buildBody(),
          desktop: _buildBody(),
          tablet: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
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
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStoreInfo(),
          _buildAvailabilityBadge(screenHeight),
        ],
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Row(
      children: [
        Icon(
          Icons.shopping_cart,
          color: AppColors.textPrimary(context),
          size: 20,
        ),
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
      height: 25,
      padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.01),
      decoration: BoxDecoration(
        color: const Color(0xffDCFCE7),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 14, color: Color(0xff166534)),
          SizedboxSpaccing.width01(context),
          Text(
            "Available",
            style: AppTextStyles.textSize12(
              context,
              color: const Color(0xff166534),
              weight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.9,
      child: Column(
        children: [
          _buildTabHeaders(screenWidth),
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildTabHeaders(double screenWidth) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      color: AppColors.containerBackground(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTab("Manual Entry", 0, FontAwesomeIcons.edit),
          _buildTab("Photo Upload", 1, FontAwesomeIcons.camera),
          _buildTab("Voice List", 2, Icons.mic),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, IconData icon) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        height: 30,
        width: screenWidth * 0.3,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTabHeader(title, icon, isSelected),
            _buildTabIndicator(screenHeight, isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildTabHeader(String title, IconData icon, bool isSelected) {
    final color = isSelected
        ? AppColors.blackColor
        : AppColors.form_hover(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 12, color: color),
        SizedboxSpaccing.width01(context),
        Text(
          title,
          style: AppTextStyles.textSize12(
            context,
            weight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTabIndicator(double screenHeight, bool isSelected) {
    return Container(
      width: 100,
      height: screenHeight * 0.005,
      color: isSelected ? AppColors.button(context) : Colors.transparent,
    );
  }

  // Widget _buildTabContent() {
  //   switch (_selectedTabIndex) {
  //     case 0:
  //       return ManualEntryTab(
  //         orderItems: orderItems,
  //         onAddItem: _addOrderItem,
  //         onRemoveItem: _removeOrderItem,
  //         notesController: notesController,
  //       );
  //     case 1:
  //       return const PhotoUploadTab();
  //     case 2:
  //       return const VoiceListTab();
  //     default:
  //       return Container();
  //   }
  // }
  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return ManualEntryTab(
          orderItems: orderItems,
          onAddItem: _addOrderItem,
          onRemoveItem: _removeOrderItem,
          notesController: notesController,
        );
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
          onRecordingChanged: (recordingPath) {
            setState(() {
              voiceRecordingPath = recordingPath;
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
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(color: AppColors.whiteColor),
      child: Row(
        children: [
          Expanded(child: _buildSaveDraftButton()),
          SizedboxSpaccing.width02(context),
          Expanded(child: _buildProceedButton()),
        ],
      ),
    );
  }

  Widget _buildSaveDraftButton() {
    return GestureDetector(
      onTap: _saveDraft,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save, size: 18, color: Colors.grey.shade700),
            SizedboxSpaccing.width01(context),
            Text(
              "Save Draft",
              style: AppTextStyles.textSize12(
                context,
                color: Colors.grey.shade700,
                weight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProceedButton() {
    return GestureDetector(
      onTap: _proceedToCheckout,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.button(context),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart, size: 18, color: Colors.white),
            SizedboxSpaccing.width01(context),
            Text(
              "Proceed",
              style: AppTextStyles.textSize12(
                context,
                color: Colors.white,
                weight: FontWeight.w400,
              ),
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