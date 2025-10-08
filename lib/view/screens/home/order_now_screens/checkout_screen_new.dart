import 'dart:convert';
import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_view_models/order_now_view_models/checkout_order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutScreenNew extends StatefulWidget {
  const CheckoutScreenNew({super.key});

  @override
  State<CheckoutScreenNew> createState() => _CheckoutScreenNewState();
}

class _CheckoutScreenNewState extends State<CheckoutScreenNew> {
  Map<String, dynamic>? storeData;
  String? businessName;
  String? status;
  String? businessType;
  String? distanceText;
  String? address;
  String? userID;
  double? storeLatitude;
  double? storeLongitude;
  String? store_logoUrl;

  // Customer location data
  String? customerFullAddress;
  double? customerLongitude;
  double? customerLatitude;

  // Order items
  List<Map<String, dynamic>> orderItems = [];
  List<Map<String, dynamic>> uploadedPhotos = [];
  String? voiceRecordingPath;
  String? notes;
  String? budget;
  String? deliveryTime;
  String orderType = '';

  // Payment method
  String? selectedPaymentMethod;

  // Payment methods data
  final List<Map<String, dynamic>> paymentMethods = [
    {'method': 'bkash', 'title': 'bkash', 'icon': FontAwesomeIcons.wallet, 'color': Color(0xFFE2136E)},
    {'method': 'nagad', 'title': 'Nagad', 'icon': FontAwesomeIcons.wallet, 'color': Color(0xFFEE4237)},
    {'method': 'cash', 'title': 'Hand Cash', 'icon': FontAwesomeIcons.sackDollar, 'color': Color(0xFF45A986)},
  ];
  Future<void> _openGoogleMapsDirections() async {
    if (customerLatitude == null || customerLongitude == null || storeLatitude == null || storeLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Location data not available", style: AppTextStyles.textSize14(context)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Google Maps URL with directions
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1'
        '&origin=$customerLatitude,$customerLongitude'
        '&destination=$storeLatitude,$storeLongitude'
        '&travelmode=driving';

    try {
      final Uri url = Uri.parse(googleMapsUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch Google Maps';
      }
    } catch (e) {
      debugPrint('Error opening Google Maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not open Google Maps", style: AppTextStyles.textSize14(context)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadArguments();
  }

  void _loadArguments() {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      storeData = arguments['storeData'];
      businessName = arguments['businessName'];
      status = arguments['status'];
      businessType = arguments['businessType'];
      distanceText = arguments['distanceText'];
      address = arguments['address'];
      userID = arguments['userID'];
      storeLatitude = arguments['storeLatitude'];
      storeLongitude = arguments['storeLongitude'];
      store_logoUrl = arguments['logoUrl'];

      // Customer location
      customerFullAddress = arguments['customerFullAddress'];
      customerLongitude = arguments['customerLongitude'];
      customerLatitude = arguments['customerLatitude'];

      // Order data
      orderItems = List<Map<String, dynamic>>.from(arguments['orderItems'] ?? []);
      uploadedPhotos = List<Map<String, dynamic>>.from(arguments['uploadedPhotos'] ?? []);
      voiceRecordingPath = arguments['voiceRecordingPath'];
      notes = arguments['notes'];
      budget = arguments['budget'];
      deliveryTime = arguments['deliveryTime'];
      orderType = arguments['orderType'] ?? 'manual';

      debugPrint('========== CHECKOUT SCREEN DATA ==========');
      debugPrint('Business: $businessName');
      debugPrint('Customer Address: $customerFullAddress');
      debugPrint('Budget: $budget');
      debugPrint('Delivery Time: $deliveryTime');
      debugPrint('Order Items: ${orderItems.length}');
      debugPrint('Photos: ${uploadedPhotos.length}');
      debugPrint('Voice: ${voiceRecordingPath != null ? "Yes" : "No"}');
      debugPrint('========================================');
    }
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
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: AppBarHeader("New Order"),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedboxSpaccing.height02(context),
                _buildOrderInfoCard(),
                SizedboxSpaccing.height02(context),
                _buildTotalItemsSection(),
                SizedboxSpaccing.height02(context),
                if (notes != null && notes!.isNotEmpty) _buildNotesSection(),
                if (notes != null && notes!.isNotEmpty) SizedboxSpaccing.height02(context),
                _buildPaymentMethodSection(),
                SizedboxSpaccing.height04(context),
                _buildActionButtons(),
                SizedboxSpaccing.height04(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfoCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.oceanGreenColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store name and icon
          Row(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessName ?? 'Store Name',
                      style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text('Under: ${businessType ?? 'Store'}', style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
                  ],
                ),
              ),
            ],
          ),

          SizedboxSpaccing.height02(context),

          // Store address section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 16, color: AppColors.button(context)),
              SizedboxSpaccing.width01(context),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Store Address', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
                    Text(
                      address ?? 'No address found',
                      style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.car, size: 12, color: AppColors.textPrimary(context)),
                        SizedboxSpaccing.width01(context),
                        Text("$distanceText", style: AppTextStyles.textSize12(context)),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            _openGoogleMapsDirections();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.directions, size: 14, color: AppColors.whiteColor),
                                SizedBox(width: 4),
                                Text('Directions', style: AppTextStyles.textSize12(context, color: AppColors.whiteColor)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedboxSpaccing.height02(context),

          // Budget, Delivery Time & Customer Address Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenHeight * 0.015),
            decoration: BoxDecoration(color: AppColors.oceanGreenColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Budget
                Row(
                  children: [
                    Text('Budget: ', style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
                    Text(
                      '৳${budget ?? '0'}',
                      style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.darkRedColor),
                    ),
                  ],
                ),

                SizedboxSpaccing.height01(context),

                // Delivery time and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
                        ),
                        Text('  By ${deliveryTime ?? ''}', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                      ],
                    ),

                    Row(
                      children: [
                        Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
                        ),
                        Text("  ${DateTime.now().toString().split(' ')[0]}", style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),

                SizedboxSpaccing.height01(context),

                // Customer delivery address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.delivery_dining, size: 18, color: AppColors.button(context)),
                    SizedboxSpaccing.width01(context),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Delivery Address', style: AppTextStyles.textSize12(context, weight: FontWeight.w600)),
                          Text(
                            customerFullAddress ?? 'No delivery address found',
                            style: AppTextStyles.textSize10(context, color: AppColors.subtitle(context)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalItemsSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    int totalItemsCount = orderItems.length + uploadedPhotos.length + (voiceRecordingPath != null ? 1 : 0);

    return Container(
      width: screenWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Items($totalItemsCount)', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
          SizedboxSpaccing.height01(context),

          // Manual entry items
          if (orderItems.isNotEmpty)
            ...orderItems.map((item) => _buildItemCard(name: item['name'] ?? 'Item', subtitle: '${item['quantity']} ${item['quantityType']}', icon: Icons.shopping_bag, iconColor: Colors.blue)),

          // Photo items
          if (uploadedPhotos.isNotEmpty) ...uploadedPhotos.map((photo) => _buildItemCard(name: photo['name'] ?? 'Grocery List', subtitle: 'Photo List', icon: Icons.image, iconColor: Colors.green)),

          // Voice recording
          if (voiceRecordingPath != null && voiceRecordingPath!.isNotEmpty) _buildItemCard(name: 'Voice Shopping List', subtitle: 'Audio recording', icon: Icons.mic, iconColor: Colors.red),
        ],
      ),
    );
  }

  Widget _buildItemCard({required String name, required String subtitle, required IconData icon, required Color iconColor}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      padding: EdgeInsets.all(screenHeight * 0.015),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
                Text(subtitle, style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Note', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
          SizedboxSpaccing.height01(context),
          Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.all(screenHeight * 0.02),
            decoration: BoxDecoration(
              color: AppColors.textFieldFill(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Text(notes ?? 'Instructions (example: use polybag)', style: AppTextStyles.textSize14(context, color: notes != null ? AppColors.textPrimary(context) : AppColors.subtitle(context))),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Text('Payment Method', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border(context), width: 1)),
            ),
            child: Column(
              children: paymentMethods.asMap().entries.map((entry) {
                final index = entry.key;
                final methodData = entry.value;
                final method = methodData['method'];
                final title = methodData['title'];
                final icon = methodData['icon'];
                final iconColor = methodData['color'];
                final isSelected = selectedPaymentMethod == method;

                return Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.015, bottom: index == paymentMethods.length - 1 ? screenHeight * 0.015 : screenHeight * 0.01),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPaymentMethod = method;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(screenHeight * 0.015),
                      decoration: BoxDecoration(color: AppColors.textFieldFill(context), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 32,
                                width: 32,
                                decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(8)),
                                child: Icon(icon, size: 16, color: AppColors.whiteColor),
                              ),
                              SizedboxSpaccing.width03(context),
                              Text(title, style: AppTextStyles.textSize16(context, weight: FontWeight.w400)),
                            ],
                          ),
                          Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? AppColors.button(context) : AppColors.border(context), width: 2),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      height: 12,
                                      width: 12,
                                      decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              // Edit order
              Navigator.pop(context);
            },
            child: Container(
              width: screenWidth * 0.42,
              child: RoundButtonFlexible(
                title: "edit",
                onPress: () {},
                showLeftIcon: true,
                showRightIcon: false,
                leftIcon: FontAwesomeIcons.edit,
                backgroundColor: AppColors.containerBackground(context),
                borderColor: AppColors.border(context),
                textColor: AppColors.textPrimary(context),
                iconColor: AppColors.textPrimary(context),
              ),
            ),
          ),

          Consumer<PostCheckOutOrderViewModel>(
            builder: (context, checkOutViewModel, child) {
              return Container(
                width: screenWidth * 0.42,
                child: RoundButtonFlexible(
                    title: "Confirm",
                    loading: checkOutViewModel.checkoutOrderLoading,
                    onPress: () async {

                      if (selectedPaymentMethod == null) {
                     Utils.flushBarErrorMessage("No payment method selected", context);
                        return;
                      }
                      if (orderItems.isEmpty && uploadedPhotos.isEmpty &&
                          (voiceRecordingPath == null || voiceRecordingPath!.isEmpty)) {
                        Utils.flushBarErrorMessage("Please add items to your order", context);
                        return;
                      }

                      Map<String, dynamic> orderData = {
                        "retailerId": userID,
                        "items": _buildOrderItemsForApi(),
                        "status": "PENDING",
                        "paymentMethod": selectedPaymentMethod,
                        "customerNote": notes?.trim(),
                        "deliveryTime": deliveryTime,
                        "budget": budget,
                        "geoLocation": {
                          "type": "Point",
                          "coordinates": [customerLongitude, customerLatitude]
                        },
                      };

                      print("🛒 Final Order Data: ${jsonEncode(orderData)}");

                      await checkOutViewModel.checkoutOrderPostApi(context, orderData);
                    },
                    showRightIcon: true,
                    showLeftIcon: false
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildOrderItemsForApi() {
    List<Map<String, dynamic>> items = [];

    // Add manual entry items
    for (var item in orderItems) {
      double quantity = double.tryParse(item['quantity']?.toString() ?? '1') ?? 1.0;
      items.add({"itemName": item['name'] ?? 'Unknown Item', "quantity": quantity, "unit": item['quantityType'] ?? 'gm'});
    }

    // Add photo items
    for (int i = 0; i < uploadedPhotos.length; i++) {
      final photo = uploadedPhotos[i];
      items.add({"itemName": photo['name'] ?? "Grocery List ${i + 1}", "quantity": 1, "unit": "photo"});
    }

    // Add voice recording
    if (voiceRecordingPath != null && voiceRecordingPath!.isNotEmpty) {
      items.add({"itemName": "Voice Shopping List", "quantity": 1, "unit": "recording"});
    }

    return items;
  }
}
