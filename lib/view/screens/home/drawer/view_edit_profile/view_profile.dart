import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.containerBackground(context), body: SafeArea(child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body())));
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return  Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)));
          },
          child: SizedBox(height: 60, child: AppBarHeader("My Profile")),
        ),
    // DrawerProfileHeader(
    // title: "$userName",
    // isActive: true,
    // phone: "$userPhone",
    // order: "0",
    // Wishlist: "0",
    // reviews: "0",
    // onImageTap: () {
    // // if (imageUrl != null && imageUrl!.isNotEmpty) {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenImage(imageUrl: "$profileImageUrl")));
    // // }
    // },
    // onCameraTap: patchprofileImageUpdateViewMode.profileImageUpdateLoading ? () {} : _handleImagePick,
    // profileImage: "$profileImageUrl",
    // );

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
}
