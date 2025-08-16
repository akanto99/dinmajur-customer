import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/drawer.dart';
import 'package:dinmajur_customer/configs/res/components/notifications/resuable_notifications.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/widgets/dynamic_dropdown.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_view_models/nearby_retailers_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const HomeScreen({super.key, this.scaffoldKey});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedStoreType;
  List<dynamic> nearbyStores = [];
  bool isLoadingStores = false;

  // Define store types - matching your API expectations
  final Map<String, String> storeTypes = {'Retail': 'রিটেল', 'grocery': 'কিরানা দোকান', 'restaurant': 'রেস্তোরাঁ', 'pharmacy': 'ফার্মেসি', 'electronics': 'ইলেকট্রনিক্স', 'clothing': 'পোশাক'};

  @override
  void initState() {
    super.initState();
  }

  // Method to fetch nearby retailers
  Future<void> _fetchNearbyRetailers(String businessType) async {
    if (!mounted) return;

    debugPrint('Starting to fetch retailers for: $businessType');

    setState(() {
      isLoadingStores = true;
      nearbyStores = [];
    });

    try {
      final viewModel = Provider.of<PostNearbyRetailersViewModel>(context, listen: false);

      final requestData = {"customer_lng": 90.3722, "customer_lat": 23.7018, "businessType": businessType};

      debugPrint('Request data: $requestData');

      // Call the API and get the response
      List<dynamic>? stores = await viewModel.nearbyRetailersPostApi(context, requestData);

      debugPrint('Received stores from API: $stores');
      debugPrint('Stores count: ${stores?.length ?? 0}');

      if (mounted && stores != null) {
        setState(() {
          nearbyStores = stores;
        });
        debugPrint('Updated nearbyStores in state: ${nearbyStores.length}');
      }
    } catch (e) {
      debugPrint('Error fetching nearby retailers: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingStores = false;
        });
        debugPrint('Loading finished. Final nearbyStores count: ${nearbyStores.length}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Only print in debug mode
    debugPrint('Current locale: ${Localizations.localeOf(context)}');
    debugPrint('Current nearbyStores length: ${nearbyStores.length}');
    debugPrint('Is loading: $isLoadingStores');
    debugPrint('Selected store type: $selectedStoreType');

    return Scaffold(
      key: widget.scaffoldKey,
      backgroundColor: AppColors.appBackground(context),
      drawer: CustomDrawer(screenHeight: screenHeight, screenWidth: screenWidth),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: AppColors.containerBackground(context),
          child: Center(child: _customAppBar(context)),
        ),
      ),
      body: SafeArea(
        child: ResPonsiveUi(mobile: _buildBody(context), desktop: _buildBody(context), tablet: _buildBody(context)),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Language Slide Switcher
          Center(child: SizedboxSpaccing.height02(context)),

          Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.all(screenHeight * 0.02),
            decoration: BoxDecoration(color: AppColors.containerBackground(context)),
            child: CustomDropdown(
              titleText: "কি লাগবে?",
              items: storeTypes.keys.toList(),
              selectedItem: selectedStoreType,
              hintText: "নির্বাচন করুন",
              onChanged: (String? newValue) {
                setState(() {
                  selectedStoreType = newValue;
                });

                // Fetch nearby retailers when selection changes
                if (newValue != null) {
                  debugPrint('Selected store type: $newValue');
                  _fetchNearbyRetailers(newValue);
                }
              },
              valueToBengaliMap: storeTypes,
            ),
          ),

          SizedboxSpaccing.height02(context),
          // Text(
          //   'নিকটবর্তী দোকান (${nearbyStores.length}টি)',
          //   style: AppTextStyles.textSize16(context,
          //       weight: FontWeight.w600
          //   ),
          // ),
          if (nearbyStores.isNotEmpty)
            _buildStoresList(),
        ],
      ),
    );
  }

  Widget _buildStoresList() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(color: AppColors.containerBackground(context)),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: nearbyStores.length,
        itemBuilder: (context, index) {
          final store = nearbyStores[index];
          return _buildStoreCard(store, screenHeight, screenWidth);
        },
      ),
    );
  }

  Widget _buildStoreCard(Map<String, dynamic> store, double screenHeight, double screenWidth) {
    debugPrint('Building store card for: $store');

    final retailer = store['retailer'] ?? {};
    final distance = store['distance']?.toDouble() ?? 0.0;
    final address = store['fullAddress'] ?? 'ঠিকানা উপলব্ধ নেই';
    final businessName = retailer['businessName'] ?? 'দোকানের নাম উপলব্ধ নেই';
    final businessType = retailer['businessType'] ?? 'অজানা';
    final userID = store['userId'] ?? '';

    debugPrint('Store details - Name: $businessName, Distance: $distance, Address: $address');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Nearest Store", style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
        SizedboxSpaccing.height01(context),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                businessName,
                style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green),
                SizedboxSpaccing.width01(context),
                Text(
                  "Available",
                  style: AppTextStyles.textSize14(context, color: Colors.green, weight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        Text(
          storeTypes[address] ?? address,
          style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedboxSpaccing.height005(context),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, size: 16, color: AppColors.textPrimary(context)),
            SizedboxSpaccing.width01(context),
            Text(
              '${distance.toStringAsFixed(0)}m away',
              style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
            ),
          ],
        ),
        SizedboxSpaccing.height01(context),
        Container(
          height: 42,
          padding: EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(0xffF0FDF4),
            border: Border.all(
              width: 1,
              color: Color(0xffBBF7D0),
            )
          ),
          child: Row(
            children: [
              Icon(Icons.access_time_filled,size: 16,color: Color(0xff15803D),),
              SizedboxSpaccing.width01(context),
              Text(
                "Delivery within 30-60 minutes",
                style: AppTextStyles.textSize14(context, color: Colors.green, weight: FontWeight.w500),
              ),
            ],
          ),
        ),
        SizedboxSpaccing.height02(context),
        GestureDetector(
          onTap: () {

            Navigator.pushNamed(
                context,
                RoutesName.orderNow,
                arguments: {
                  'storeData': store,
                  'retailer': retailer,
                  'distance': distance,
                  'address': address,
                  'businessName': businessName,
                  'businessType': businessType,
                  'selectedStoreType': selectedStoreType,
                  'userID': userID,
                }
            );
          },
          child: Container(
            height: 50,
            padding: EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.button(context),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart,size: 16,color: AppColors.whiteColor,),
                SizedboxSpaccing.width01(context),
                Text(
                  "Order Now",
                  style: AppTextStyles.textSize14(context,color: AppColors.whiteColor, weight: FontWeight.w500),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _customAppBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1.0)),
      ),
      child: Center(
        child: Container(
          width: screenWidth * 0.9,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Side - User Profile
              Flexible(
                flex: 3,
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.appBackground(context),
                            border: Border.all(width: 1, color: AppColors.textPrimary(context)),
                          ),
                          child: Icon(Icons.person, color: AppColors.textPrimary(context), size: 20),
                        ),
                      ),
                    ),

                    SizedboxSpaccing.width02(context),

                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Md Nahid Hassan Akanto",
                            style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: AppColors.textPrimary(context)),
                              Expanded(
                                child: Text(
                                  "1234 Elm Street, Downtown",
                                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Right Side Icons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconButton(
                    onTap: () {
                      NotificationDialog.show(
                        context,
                        message: 'Empty Inbox',
                        icon: CupertinoIcons.text_bubble,
                        iconColor: AppColors.textPrimary(context),
                        iconBackgroundColor: AppColors.appBackground(context),
                      );
                    },
                    svgAsset: 'assets/images/home/email.svg',
                    context: context,
                  ),

                  SizedboxSpaccing.width02(context),

                  _buildIconButton(
                    onTap: () {
                      NotificationDialog.show(
                        context,
                        message: 'No Notification Yet',
                        icon: Icons.notifications_outlined,
                        iconColor: AppColors.textPrimary(context),
                        iconBackgroundColor: AppColors.appBackground(context),
                      );
                    },
                    svgAsset: 'assets/images/home/notification.svg',
                    context: context,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({required VoidCallback onTap, required String svgAsset, required BuildContext context}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 24,
        width: 24,
        padding: const EdgeInsets.all(2),
        child: SvgPicture.asset(svgAsset, color: AppColors.textPrimary(context), fit: BoxFit.contain),
      ),
    );
  }
}
