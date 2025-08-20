import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_view_models/order_now_view_models/checkout_order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/custom_appbar.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Order data properties
  Map<String, dynamic>? storeData;
  String? businessName;
  List<Map<String, dynamic>> orderItems = [];
  List<Map<String, dynamic>> uploadedPhotos = [];
  String? voiceRecordingPath;
  String? notes;
  String orderType = '';
  String? userID;

  // Pricing
  double subtotal = 0.0;
  double deliveryFee = 3.99;
  double tax = 0.0;

  // Weight type display mapping
  final Map<String, String> weightTypeDisplay = {
    'gm': 'grams',
    'kg': 'kg',
    'L': 'liters',
    'pcs': 'pieces',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadArguments();
    _calculatePricing();
  }

  void _loadArguments() {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      storeData = arguments['storeData'];
      businessName = arguments['businessName'];
      orderItems = List<Map<String, dynamic>>.from(arguments['orderItems'] ?? []);
      uploadedPhotos = List<Map<String, dynamic>>.from(arguments['uploadedPhotos'] ?? []);
      voiceRecordingPath = arguments['voiceRecordingPath'];
      notes = arguments['notes'];
      orderType = arguments['orderType'] ?? 'manual';
      userID = arguments['userID'];
    }
  }

  void _calculatePricing() {
    subtotal = 0.0;

    // Calculate from manual entry items
    subtotal += orderItems.fold(0.0, (sum, item) {
      double price = double.tryParse(item['estimatedPrice']?.toString() ?? '0') ?? 4.50;
      return sum + price;
    });

    // Calculate from uploaded photos
    subtotal += uploadedPhotos.length * 8.00; // $8 per photo processing

    // Calculate from voice recording
    if (voiceRecordingPath != null && voiceRecordingPath!.isNotEmpty) {
      subtotal += 5.00; // $5 for voice processing
    }

    tax = subtotal * 0.10; // 10% tax
    setState(() {});
  }

  // Format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return "${bytes}B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)}KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB";
  }

  // Get proper unit display for manual items
  String _getUnitDisplay(String quantityType) {
    return weightTypeDisplay[quantityType] ?? quantityType;
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Draft saved successfully", style: AppTextStyles.textSize14(context)),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Helper method to remove item from order
  void _removeItem(int index, String itemType) {
    setState(() {
      if (itemType == 'manual') {
        orderItems.removeAt(index);
      } else if (itemType == 'photo') {
        uploadedPhotos.removeAt(index);
      } else if (itemType == 'voice') {
        voiceRecordingPath = null;
      }
    });
    _calculatePricing();
  }

  // Build order items for API
  List<Map<String, dynamic>> _buildOrderItemsForApi() {
    List<Map<String, dynamic>> items = [];

    // Add manual entry items
    for (var item in orderItems) {
      // Parse quantity properly
      double quantity = double.tryParse(item['quantity']?.toString() ?? '1') ?? 1.0;
      double unitPrice = double.tryParse(item['estimatedPrice']?.toString() ?? '0') ?? 4.50;
      String quantityType = item['quantityType'] ?? 'gm';

      items.add({
        "name": item['name'] ?? 'Unknown Item',
        "quantity": quantity,
        "unit": _getApiUnit(quantityType),
        "unitPrice": unitPrice,
        "totalPrice": unitPrice, // Since unitPrice already calculated for total quantity
      });
    }

    // Add photo items
    for (int i = 0; i < uploadedPhotos.length; i++) {
      final photo = uploadedPhotos[i];
      items.add({
        "itemName": photo['name'] ?? "Grocery List ${i + 1}",
        "quantity": 1,
        "unit": "photo",
        "unitPrice": 8.00,
        "totalPrice": 100,
        // "type": "photo",
        // "photoPath": photo['path'] ?? "",
        // "fileSize": photo['size'] ?? 0,
      });
    }

    // Add voice recording item
    if (voiceRecordingPath != null && voiceRecordingPath!.isNotEmpty) {
      items.add({
        "itemName": "Voice Shopping List",
        "quantity": 1,
        "unit": "recording",
        "price": 5.00,
        "type": "voice",
        "voicePath": voiceRecordingPath,
      });
    }

    return items;
  }

  // Helper to get API unit format
  String _getApiUnit(String quantityType) {
    switch (quantityType) {
      case 'kg':
        return 'kg';
      case 'gm':
        return 'gm';
      case 'lr':
        return 'ltr';
      case 'pics':
        return 'pcs';
      default:
        return quantityType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(mobile: _buildBody(), desktop: _buildBody(), tablet: _buildBody()),
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
                _buildStoreSection(),
                SizedboxSpaccing.height02(context),
                _buildDeliveryAddress(),
                SizedboxSpaccing.height02(context),
                _buildPaymentMethod(),
                SizedboxSpaccing.height02(context),
                _buildOrderSummary(),
                SizedboxSpaccing.height02(context),
                _buildPricingSection(),
                SizedboxSpaccing.height04(context),
              ],
            ),
          ),
        ),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildAppBar() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: const CustomAppBar(appBarTitle: "Checkout"),
    );
  }

  Widget _buildStoreSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(color: AppColors.containerBackground(context)),
      child: Row(
        children: [
          Icon(Icons.shopping_cart, color: AppColors.textPrimary(context), size: 20),
          SizedboxSpaccing.width02(context),
          Text(businessName ?? 'Fresh Bazaar', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xffDCFCE7), borderRadius: BorderRadius.circular(50)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, size: 12, color: Color(0xff166534)),
                SizedboxSpaccing.width01(context),
                Text(
                  "Available",
                  style: AppTextStyles.textSize12(context, color: const Color(0xff166534), weight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(color: AppColors.containerBackground(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Delivery Address", style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
          SizedboxSpaccing.height01(context),
          Container(
            padding: EdgeInsets.all(screenHeight * 0.015),
            decoration: BoxDecoration(
              color: AppColors.textFieldFill(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Home", style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                      SizedboxSpaccing.height005(context),
                      Text("123 Main Street, Apt 4B", style: AppTextStyles.textSize12(context, color: Colors.grey)),
                    ],
                  ),
                ),
                Icon(Icons.edit_outlined, size: 20, color: AppColors.textPrimary(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(color: AppColors.containerBackground(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Payment Method", style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
          SizedboxSpaccing.height01(context),
          Container(
            padding: EdgeInsets.all(screenHeight * 0.015),
            decoration: BoxDecoration(
              color: AppColors.textFieldFill(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 20,
                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(4)),
                  child: const Center(
                    child: Text(
                      'VISA',
                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedboxSpaccing.width02(context),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Visa ending in 4242", style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                      Text("Expires 12/25", style: AppTextStyles.textSize12(context, color: Colors.grey)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(color: AppColors.containerBackground(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Order Summary", style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
          SizedboxSpaccing.height01(context),

          // Manual Entry Items
          if (orderItems.isNotEmpty)
            ...orderItems.asMap().entries.map(
                  (entry) => _buildOrderItem(
                title: entry.value['name'] ?? 'Unknown Item',
                subtitle: "${entry.value['quantity'] ?? '1'} ${_getUnitDisplay(entry.value['quantityType'] ?? 'gm')}",
                price: double.tryParse(entry.value['estimatedPrice']?.toString() ?? '0') ?? 4.50,
                showDelete: true,
                onDelete: () => _removeItem(entry.key, 'manual'),
              ),
            ),

          // Photo Items
          if (uploadedPhotos.isNotEmpty)
            ...uploadedPhotos.asMap().entries.map(
                  (entry) => _buildOrderItem(
                title: entry.value['name'] ?? "Grocery List ${entry.key + 1}",
                subtitle: "${_formatFileSize(entry.value['size'] ?? 0)} • Photo List",
                price: 8.00,
                showDelete: true,
                isPhoto: true,
                onDelete: () => _removeItem(entry.key, 'photo'),
              ),
            ),

          // Voice Recording Item
          if (voiceRecordingPath != null && voiceRecordingPath!.isNotEmpty)
            _buildOrderItem(
              title: "Voice Shopping List",
              subtitle: "Audio recording • Voice List",
              price: 5.00,
              showDelete: true,
              isVoice: true,
              onDelete: () => _removeItem(0, 'voice'),
            ),

          // Notes section
          if (notes != null && notes!.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: screenHeight * 0.015),
              padding: EdgeInsets.all(screenHeight * 0.015),
              decoration: BoxDecoration(
                color: AppColors.textFieldFill(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.note, size: 16, color: AppColors.textPrimary(context)),
                      SizedboxSpaccing.width01(context),
                      Text(
                        "Order Notes:",
                        style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedboxSpaccing.height005(context),
                  Text(
                    notes!,
                    style: AppTextStyles.textSize12(context, color: Colors.grey),
                  ),
                ],
              ),
            ),

          // Show message if no items
          if (orderItems.isEmpty && uploadedPhotos.isEmpty && (voiceRecordingPath == null || voiceRecordingPath!.isEmpty))
            Container(
              padding: EdgeInsets.all(screenHeight * 0.02),
              child: Center(
                child: Text("No items in your order", style: AppTextStyles.textSize14(context, color: Colors.grey)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItem({
    required String title,
    required String subtitle,
    required double price,
    bool showDelete = false,
    bool isPhoto = false,
    bool isVoice = false,
    VoidCallback? onDelete,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      padding: EdgeInsets.all(screenHeight * 0.015),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          if (isPhoto)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.image, size: 20, color: Colors.grey),
            )
          else if (isVoice)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.mic, size: 20, color: Colors.red),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.shopping_bag, size: 20, color: Colors.blue),
            ),

          SizedboxSpaccing.width02(context),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                Text(subtitle, style: AppTextStyles.textSize12(context, color: Colors.grey)),
              ],
            ),
          ),

          Text("৳${price.toStringAsFixed(2)}", style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),

          if (showDelete && onDelete != null) ...[
            SizedboxSpaccing.width01(context),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final total = subtotal + deliveryFee + tax;

    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(color: AppColors.containerBackground(context)),
      child: Column(
        children: [
          _buildPriceRow("Subtotal", subtotal),
          _buildPriceRow("Delivery Fee", deliveryFee),
          _buildPriceRow("Tax", tax),
          Divider(color: AppColors.border(context)),
          _buildPriceRow("Total", total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.textSize14(context, weight: isTotal ? FontWeight.w600 : FontWeight.w400)),
          Text("৳${amount.toStringAsFixed(2)}", style: AppTextStyles.textSize14(context, weight: isTotal ? FontWeight.w600 : FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(child: _buildSaveDraftButton()),
          SizedboxSpaccing.width02(context),
          Expanded(child: _buildPlaceOrderButton()),
        ],
      ),
    );
  }

  Widget _buildSaveDraftButton() {
    return GestureDetector(
      onTap: _saveDraft,
      child: Container(
        height: 48,
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
              style: AppTextStyles.textSize14(context, color: Colors.grey.shade700, weight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
    return Consumer<PostCheckOutOrderViewModel>(
      builder: (context, checkOutViewModel, child) {
        return GestureDetector(
          onTap: () async {
            // Validate order before placing
            if (orderItems.isEmpty && uploadedPhotos.isEmpty && (voiceRecordingPath == null || voiceRecordingPath!.isEmpty)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Please add items to your order", style: AppTextStyles.textSize14(context)),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            if (userID == null || userID!.isEmpty) {
              print(userID);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("User ID is required", style: AppTextStyles.textSize14(context)),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            try {
              // Build order data
              final total = subtotal + deliveryFee + tax;

              Map<String, dynamic> orderData = {
                "retailerId": userID,
                "items": _buildOrderItemsForApi(),
                "status": "PENDING",
                "vat": tax,
                "vatPercent": 10.0,
                "deliveryFee": deliveryFee,
                "subTotalAmount": subtotal,
                "totalAmount": total,
                // "orderType": orderType,
                // "notes": notes?.trim(),
              };

              debugPrint("🛒 Placing order with data: $orderData");

              // Call the API
              await checkOutViewModel.checkoutOrderPostApi(context, orderData);

            } catch (error) {
              debugPrint("❌ Error placing order: $error");
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Failed to place order. Please try again.", style: AppTextStyles.textSize14(context)),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(4)),
            child: checkOutViewModel.checkoutOrderLoading
                ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 18, color: Colors.white),
                SizedboxSpaccing.width01(context),
                Text(
                  "Place Order",
                  style: AppTextStyles.textSize14(context, color: Colors.white, weight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}