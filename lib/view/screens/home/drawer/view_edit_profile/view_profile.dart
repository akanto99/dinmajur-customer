import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  // Sample data
  String profileImage = "https://example.com/profile.jpg"; // Replace with actual image
  String title = "Emily Johnson";
  String phone = "01833182808";
  bool isActive = true;

  int _currentIndex = 0;
  int _tappedIndex = -1;
  final List<String> icons = [
    "assets/images/navBar/navbar_new/home.svg",
    "assets/images/navBar/navbar_new/scan.svg",
    "assets/images/navBar/navbar_new/task.svg",
    "assets/images/navBar/navbar_new/stores.svg",
    "assets/images/navBar/navbar_new/income.svg",
  ];
  final List<String> labels = ["Home", "Scan", "Task", "Stores", "Income"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(
          mobile: body(),
          desktop: body(),
          tablet: body(),
        ),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Header
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationScreen(initialIndex: 0),
              ),
            );
          },
          child: SizedBox(height: 60, child: AppBarHeader("My Profile")),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              width: screenWidth*0.9,
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  _buildProfileCard(screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.02),
                  _buildStatsCard(screenWidth, screenHeight),

                  SizedBox(height: screenHeight * 0.02),

                  // Personal Information
                  _buildPersonalInformation(screenWidth, screenHeight),

                  SizedBox(height: screenHeight * 0.025),

                  // Delivery Address
                  _buildDeliveryAddress(screenWidth, screenHeight),

                  SizedBox(height: screenHeight * 0.025),

                  // Recent Orders
                  _buildRecentOrders(screenWidth, screenHeight),

                  SizedBox(height: screenHeight * 0.025),

                  // Back to Dashboard Button
                  _buildBackButton(screenWidth),

                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ),

        /// Fixed navigation bar at bottom
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.globalBlackWhite(context),
            boxShadow: [BoxShadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.white12.withOpacity(0.02) : Colors.white10, blurRadius: 10, offset: Offset(0, -2))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Divider(color: AppColors.border(context), height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(icons.length, (index) {
                  bool isSelected = _currentIndex == index;
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        _tappedIndex = index;
                      });
                      await Future.delayed(Duration(milliseconds: 300));
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: index)));
                      print(index);
                      setState(() {
                        _tappedIndex = -1;
                      });
                    },
                    child: Container(
                      width: screenWidth * 0.2,
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            icons[index],
                            width: 20,
                            height: 20,
                            color: isSelected ? AppColors.button(context) : AppColors.subtitle(context),
                            semanticsLabel: labels[index], // Accessibility
                          ),
                          const SizedBox(height: 6),
                          Text(
                            labels[index],
                            style: AppTextStyles.textSize12(
                              context,
                              weight: isSelected ? FontWeight.w500 : FontWeight.w400,
                              color: isSelected ? AppColors.button(context) : AppColors.subtitle(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              Container(height: 1),
            ],
          ),
        ),
      ],
    );
  }



Widget _buildProfileCard(double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.globalBlackWhite(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.textFieldFill(context),
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color: AppColors.border(context)
                  )
                ),
                child: Center(
                  child: Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textFieldFill(context),
                      border: Border.all(width: 1, color: AppColors.button(context)),
                      image: DecorationImage(
                        image: NetworkImage(profileImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 0,
                child: Container(
                  height: 19,
                  width: 19,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.border(context),
                  ),
                  child: Icon(Icons.camera_alt, size: 10, color: AppColors.textPrimary(context)),
                ),
              ),
            ],
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  phone,
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(double screenWidth, double screenHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("24", "Orders"),
        _buildVerticalDivider(),
        _buildStatItem("12k", "Spent"),
        _buildVerticalDivider(),
        _buildStatItem("8", "Reviews"),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    final screenWidth = MediaQuery.of(context).size.width*1;
    final screenHeight = MediaQuery.of(context).size.height*1;
    return Container(
      height: 68,
      width: screenWidth*0.26,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: 1,
          color: AppColors.border(context)
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.textSize18(context, weight: FontWeight.w500,    color: AppColors.subtitle(context),),
          ),
          Text(
            label,
            style: AppTextStyles.textSize14(
              context,
              weight: FontWeight.w400,
              color: AppColors.subtitle(context),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.border(context),
    );
  }

  Widget _buildPersonalInformation(double screenWidth, double screenHeight) {
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
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Text(
              "Personal Information",
              style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
            ),
          ),
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
              ),
              border: Border(top: BorderSide(
                  width: 1, color: AppColors.border(context)
              )
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.phone, "+1 234 567 8900"),
                SizedBox(height: screenHeight * 0.015),
                _buildInfoRow(Icons.calendar_today_outlined, "Member since: 15 Aug, 2023"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textPrimary(context)),
        SizedboxSpaccing.width03(context),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddress(double screenWidth, double screenHeight) {
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
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Delivery Address",
                  style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
                ),
                GestureDetector(
                  onTap: (){

                  },
                  child: Text(
                    "Change",
                    style: AppTextStyles.textSize12(context, weight: FontWeight.w500,     color: AppColors.button(context),),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border(top: BorderSide(
                  width: 1, color: AppColors.border(context)
              )
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 20, color: AppColors.subtitle(context)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "123 Market Street, Suite 200",
                        style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                      ),
                      Text(
                        "San Francisco, CA 94103",
                        style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(double screenWidth, double screenHeight) {
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
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Orders",
                  style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
                ),
                GestureDetector(
                  onTap: (){

                  },
                  child: Text(
                    "View All",
                    style: AppTextStyles.textSize12(context, weight: FontWeight.w500,     color: AppColors.button(context),),
                  ),
                ),
              ],
            ),
          ),

          Container(
              padding: EdgeInsets.all(screenHeight * 0.02),
              decoration: BoxDecoration(
                color: AppColors.containerBackground(context),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                border: Border(top: BorderSide(
                    width: 1, color: AppColors.border(context)
                )
                ),
              ),
              child: _buildOrderItem("Order #1024", "Delivered", "\$125.50")),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String orderId, String status, String amount) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.textFieldFill(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.shopping_bag, color: AppColors.subtitle(context)),
          ),
        SizedboxSpaccing.width03(context),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderId,
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400,color: AppColors.textPrimary(context)),
                ),
                Text(
                  status,
                  style: AppTextStyles.textSize12(
                    context,
                    weight: FontWeight.w400,
                    color: AppColors.subtitle(context),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(double screenWidth) {
    return           GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)));
      },
      child: Container(
        height: 50,
        width: screenWidth * 0.68,
        decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.arrowLeft, size: 16, color: AppColors.whiteColor),
            SizedboxSpaccing.width03(context),
            Text(
              'Back to Dashboard',
              style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.whiteColor),
            ),
          ],
        ),
      ),
    );
  }
}