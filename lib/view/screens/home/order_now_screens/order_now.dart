import 'dart:typed_data';

import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/custom_appbar.dart';
import 'package:dinmajur_customer/configs/res/components/full_screen_image/full_image_viewer.dart';
import 'package:dinmajur_customer/configs/res/components/full_screen_image/full_screen_image_2.dart';
import 'package:dinmajur_customer/configs/res/components/image_picker/image_picker_only.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderNow extends StatefulWidget {
  const OrderNow({super.key});

  @override
  State<OrderNow> createState() => _OrderNowState();
}

class _OrderNowState extends State<OrderNow> {
  Map<String, dynamic>? storeData;
  Map<String, dynamic>? retailer;
  double? distance;
  String? address;
  String? businessName;
  String? businessType;
  String? selectedStoreType;

  TextEditingController itemNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController(text: '1');
  TextEditingController notesController = TextEditingController();

  String quantityType = 'Quantity'; // 'Quantity' or 'Weight'
  List<Map<String, dynamic>> orderItems = [];
  int _selectedTabIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the arguments passed from HomeScreen
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      storeData = arguments['storeData'];
      retailer = arguments['retailer'];
      distance = arguments['distance'];
      address = arguments['address'];
      businessName = arguments['businessName'];
      businessType = arguments['businessType'];
      selectedStoreType = arguments['selectedStoreType'];
    }
  }

  void _addItem() {
    if (itemNameController.text.trim().isNotEmpty && quantityController.text.trim().isNotEmpty) {
      setState(() {
        orderItems.add({'name': itemNameController.text.trim(), 'quantity': quantityController.text.trim(), 'quantityType': quantityType});
      });

      // Clear the form
      itemNameController.clear();
      quantityController.text = '1';
    }
  }

  void _removeItem(int index) {
    setState(() {
      orderItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: CustomAppBar(appBarTitle: "New Order"),
        ),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedboxSpaccing.height02(context),
                if (businessName != null) _buildStoreInfoCard(),

                SizedboxSpaccing.height02(context),

                // Tab Section
                _buildTabSection(),

                SizedboxSpaccing.height02(context),

                // Action Buttons
                _buildActionButtons(),

                SizedboxSpaccing.height04(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreInfoCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(color: AppColors.containerBackground(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                Icon(Icons.shopping_cart, color: AppColors.textPrimary(context), size: 20),
                SizedboxSpaccing.width02(context),
                Text(
                  businessName ?? 'Store Name',
                  style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            height: 25,
            padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.01),
            decoration: BoxDecoration(color: Color(0xffDCFCE7), borderRadius: BorderRadius.circular(50)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 14, color: Color(0xff166534)),
                SizedboxSpaccing.width01(context),
                Text(
                  "Available",
                  style: AppTextStyles.textSize12(context, color: Color(0xff166534), weight: FontWeight.w400),
                ),
              ],
            ),
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
      child: Column(
        children: [
          // Tab Headers
          Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
            color: AppColors.containerBackground(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildTab("Manual Entry", 0, FontAwesomeIcons.edit), _buildTab("Photo Upload", 1, FontAwesomeIcons.camera), _buildTab("Voice List", 2, Icons.mic)],
            ),
          ),

          // Tab Content
          Container(
            child: _getSelectedWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, IconData icon) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        height: 30,

        width: screenWidth * 0.3,
        decoration: BoxDecoration(color: Colors.transparent),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 12, color: isSelected ? AppColors.blackColor : AppColors.form_hover(context)),
                SizedboxSpaccing.width01(context),
                Text(
                  title,
                  style: AppTextStyles.textSize12(context, weight: FontWeight.w500, color: isSelected ? AppColors.blackColor : AppColors.form_hover(context)),
                ),
              ],
            ),
            Container(width: 100, height: screenHeight * 0.005, color: isSelected ? AppColors.button(context) : Colors.transparent),
          ],
        ),
      ),
    );
  }

  Widget _getSelectedWidget() {
    switch (_selectedTabIndex) {
      case 0:
        return WidgetManualEntryTab();
      case 1:
        return WidgetPhotoUploadTab();
      case 2:
        return WidgetVoiceListTab();
      default:
        return Container();
    }
  }

  Widget WidgetManualEntryTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
          color: AppColors.containerBackground(context),
          padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Items List (if any exist)
              if (orderItems.isNotEmpty) ...[_buildOrderItemsList(), SizedboxSpaccing.height02(context)],

              CustomTextFormField(titleText: "Item Name", placeholder: "e.g., Tomatoes, Basmati Rice...", controller: itemNameController),

              SizedboxSpaccing.height02(context),

              Row(
                children: [
                  Text("Quantity Type:", style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                  SizedboxSpaccing.width02(context),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(screenHeight * 0.01),
                      decoration: BoxDecoration(color: AppColors.appBackground(context), borderRadius: BorderRadius.circular(6)),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => quantityType = 'Quantity'),
                              child: Container(
                                height: 25,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(color: quantityType == 'Quantity' ? AppColors.whiteColor : AppColors.appBackground(context), borderRadius: BorderRadius.circular(4)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.numbers, size: 16, color: quantityType == 'Quantity' ? AppColors.blackColor : AppColors.form_hover(context)),
                                    SizedboxSpaccing.width01(context),
                                    Text(
                                      "Quantity",
                                      style: AppTextStyles.textSize14(context, color: quantityType == 'Quantity' ? AppColors.blackColor : AppColors.form_hover(context), weight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () => setState(() => quantityType = 'Weight'),
                              child: Container(
                                height: 25,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(color: quantityType == 'Weight' ? AppColors.whiteColor : AppColors.appBackground(context), borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(FontAwesomeIcons.scaleBalanced, size: 14, color: quantityType == 'Weight' ? AppColors.blackColor : AppColors.form_hover(context)),
                                    SizedboxSpaccing.width02(context),
                                    Text(
                                      "Weight",
                                      style: AppTextStyles.textSize14(context, color: quantityType == 'Weight' ? AppColors.blackColor : AppColors.form_hover(context), weight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedboxSpaccing.height02(context),

              // Quantity Input with Counter
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      int currentValue = int.tryParse(quantityController.text) ?? 1;
                      if (currentValue > 1) {
                        quantityController.text = (currentValue - 1).toString();
                      }
                    },
                    child: Container(
                      width: 25,
                      height: 35,
                      decoration: BoxDecoration(
                        color: AppColors.appBackground(context),
                        border: Border.all(color: AppColors.border(context)),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                      ),
                      child: Icon(Icons.remove, size: 16),
                    ),
                  ),
                  Container(
                    width: 55,
                    height: 35,
                    decoration: BoxDecoration(
                      color: AppColors.containerBackground(context),
                      border: Border(
                        top: BorderSide(width: 1, color: AppColors.border(context)),
                        bottom: BorderSide(width: 1, color: AppColors.border(context)),
                      ),
                    ),
                    child: TextFormField(
                      controller: quantityController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      int currentValue = int.tryParse(quantityController.text) ?? 1;
                      quantityController.text = (currentValue + 1).toString();
                    },
                    child: Container(
                      width: 25,
                      height: 35,
                      decoration: BoxDecoration(
                        color: AppColors.appBackground(context),
                        border: Border.all(color: AppColors.border(context)),
                        borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                      ),
                      child: Icon(Icons.add, size: 16),
                    ),
                  ),
                ],
              ),

              SizedboxSpaccing.height02(context),

              // Add Item Button
              GestureDetector(
                onTap: _addItem,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: AppColors.whiteColor, size: 20),
                      SizedboxSpaccing.width01(context),
                      Text(
                        "Add Item",
                        style: AppTextStyles.textSize14(context, color: Colors.white, weight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),

              SizedboxSpaccing.height02(context),
            ],
          ),
        ),
          SizedboxSpaccing.height02(context),
        _buildNotesSection(),
      ],
    );
  }
  List<SelectedImage> _selectedImages = [];
  Widget WidgetPhotoUploadTab() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // Upload Section
        Container(
          width: screenWidth * 0.9,
          color: AppColors.containerBackground(context),
          child: Padding(
            padding: EdgeInsets.only(
              left: screenHeight * 0.02,
              right: screenHeight * 0.02,
              bottom: screenHeight * 0.02,
            ),
            child: Container(
              height: 195,
              padding: EdgeInsets.all(screenHeight * 0.02),
              decoration: BoxDecoration(
                color: AppColors.textFieldFill(context),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(width: 1, color: AppColors.border(context)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_camera, size: 35, color: Colors.grey),
                  SizedboxSpaccing.height01(context),
                  Text(
                    "Take a photo of your bazaar list or\nupload from gallery",
                    style: AppTextStyles.textSize14(context, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedboxSpaccing.height02(context),
                  GestureDetector(
                    onTap: () {
                      ImagePickerOnly.pickImageWithSourceSelection(
                        context: context,
                        onImagePicked: (Uint8List imageData) {
                          setState(() {
                            _selectedImages.add(SelectedImage(
                              imageData: imageData,
                              name: "Bazaar List ${_selectedImages.length + 1}",
                              timestamp: DateTime.now(),
                            ));
                          });
                        },
                      );
                    },
                    child: Container(
                      width: screenHeight * 0.3,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.button(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.upload, color: Colors.white, size: 20),
                          SizedboxSpaccing.width02(context),
                          Text(
                            "Upload Bazaar List",
                            style: AppTextStyles.textSize16(
                              context,
                              color: Colors.white,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedboxSpaccing.height02(context),

        // Photo List Section
        Container(
          width: screenWidth * 0.9,
          color: AppColors.containerBackground(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedImages.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.all(screenHeight * 0.02),
                  child: Text(
                    "Uploaded Photos (${_selectedImages.length})",
                    style: AppTextStyles.textSize16(
                      context,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  height: _selectedImages.isEmpty ? 50 : 200, // Dynamic height
                  child: _selectedImages.isEmpty
                      ? Center(
                    child: Text(
                      "No photos uploaded yet",
                      style: AppTextStyles.textSize14(context, color: Colors.grey),
                    ),
                  )
                      : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      final image = _selectedImages[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: screenHeight * 0.01),
                        padding: EdgeInsets.all(screenHeight * 0.015),
                        decoration: BoxDecoration(
                          color: AppColors.textFieldFill(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: 1,
                            color: AppColors.border(context),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Image thumbnail
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.border(context),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.memory(
                                  image.imageData,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            SizedboxSpaccing.width02(context),

                            // Image details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    image.name,
                                    style: AppTextStyles.textSize14(
                                      context,
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "${_formatTimestamp(image.timestamp)} • ${_formatFileSize(image.imageData.length)}",
                                    style: AppTextStyles.textSize12(
                                      context,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Action buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FullScreenImage2(imageData: image.imageData, imageName: image.name)
                                        )
                                    );                                  },
                                  icon: Icon(
                                    Icons.visibility,
                                    color: AppColors.textPrimary(context),
                                    size: 20,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _removeImage(index),
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedboxSpaccing.height02(context),
              ] else ...[
                Container(
                  height: 100,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library_outlined,
                            size: 40,
                            color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          "No photos uploaded yet",
                          style: AppTextStyles.textSize14(context, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget WidgetVoiceListTab() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(left: screenHeight * 0.02, right: screenHeight * 0.02, bottom: screenHeight * 0.02),
      child: Container(
        height: 195,
        padding: EdgeInsets.all(screenHeight * 0.02),
        decoration: BoxDecoration(
          color: AppColors.textFieldFill(context),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(width: 1, color: AppColors.border(context)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic, size: 35, color: Colors.grey),
            SizedboxSpaccing.height01(context),
            Text(
              "Record your shopping list by voice",
              style: AppTextStyles.textSize14(context, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedboxSpaccing.height02(context),
            Container(
              width: screenHeight * 0.3,
              height: 48,
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic, color: Colors.white, size: 20),
                  SizedboxSpaccing.width01(context),
                  Text(
                    "Start Recording",
                    style: AppTextStyles.textSize16(context, color: Colors.white, weight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsList() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Order Items (${orderItems.length})", style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
        SizedboxSpaccing.height01(context),
        Container(
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: orderItems.length,
            separatorBuilder: (context, index) => SizedBox(height: screenHeight * 0.01), // Add spacing between items
            itemBuilder: (context, index) {
              final item = orderItems[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.textFieldFill(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 1, color: AppColors.border(context)),
                ),
                padding: EdgeInsets.all(screenHeight * 0.015),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'], style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                          Text("${item['quantity']} ${item['quantityType'] == 'Weight' ? 'kg' : 'pcs'}", style: AppTextStyles.textSize12(context, color: Colors.grey)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeItem(index),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Icon(Icons.delete, size: 16, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: AppColors.containerBackground(context),
      padding: EdgeInsets.all(screenHeight * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Notes", style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
          SizedboxSpaccing.height012(context),
          Container(
            width: screenWidth * 0.9,
            // height: screenHeight*0.05,
            decoration: BoxDecoration(
              color: AppColors.textFieldFill(context),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 1, color: AppColors.border(context)),
            ),
            child: TextField(
              controller: notesController,
              maxLines: 6,
              style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
              decoration: InputDecoration(
                hintText: "Special instructions (e.g., 'ripe avocado')",
                hintStyle: AppTextStyles.textSize12(context, color: AppColors.hintColor(context), weight: FontWeight.w400),
                border: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
              ),
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
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(color: AppColors.whiteColor),
      child: Row(
        children: [
          // Save Draft Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Draft saved successfully", style: AppTextStyles.textSize14(context)),
                    backgroundColor: AppColors.whiteColor,
                  ),
                );
              },
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
                      style: AppTextStyles.textSize12(context, color: Colors.grey.shade700, weight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Spacing between buttons
          SizedboxSpaccing.width02(context),

          // Proceed Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Proceed to checkout functionality
                if (orderItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please add at least one item to proceed"), backgroundColor: Colors.red));
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Proceeding to checkout with ${orderItems.length} items"), backgroundColor: Colors.green));
              },
              child: Container(
                height: 42,
                decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(4)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart, size: 18, color: Colors.white),
                    SizedboxSpaccing.width01(context),
                    Text(
                      "Proceed",
                      style: AppTextStyles.textSize12(context, color: Colors.white, weight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return "${bytes}B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)}KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB";
  }
  @override
  void dispose() {
    itemNameController.dispose();
    quantityController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
class SelectedImage {
  final Uint8List imageData;
  final String name;
  final DateTime timestamp;

  SelectedImage({
    required this.imageData,
    required this.name,
    required this.timestamp,
  });
}