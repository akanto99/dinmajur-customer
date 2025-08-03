import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/drawer.dart';
import 'package:dinmajur_customer/configs/res/components/notifications/resuable_notifications.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';


class HomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const HomeScreen({super.key, this.scaffoldKey});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: widget.scaffoldKey,
      backgroundColor: AppColors.containerBackground(context),
      drawer: CustomDrawer(screenHeight: screenHeight, screenWidth: screenWidth),
      appBar: PreferredSize(preferredSize: Size.fromHeight(60), child: Container(color: AppColors.containerBackground(context), child: Center(child: _customAppBar(context)))),
      body: SafeArea(child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body())),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return Column(
      children: [

      ],
    );
  }

  Widget _customAppBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1.0))),
      child: Center(
        child: Container(
          // color: AppColors.blackColor,
          width: screenWidth*0.9,
          // padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder:
                    (context) => GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.appBackground(context), border: Border.all(width: 1, color: AppColors.textPrimary(context))),
                    child:Icon(Icons.person, color: AppColors.textPrimary(context), size: 20),
                  ),
                ),
              ),
              // Right Side Icons
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      NotificationDialog.show(
                        context,
                        message: 'Empty Inbox',
                        icon: CupertinoIcons.text_bubble,
                        iconColor: AppColors.textPrimary(context),
                        iconBackgroundColor: AppColors.appBackground(context),
                      );
                    },
                    child: Container(height: 20, width: 20, child: SvgPicture.asset('assets/images/home/email.svg', color: AppColors.textPrimary(context))),
                  ),
                  SizedboxSpaccing.width02(context),
                  GestureDetector(
                    onTap: () {
                      NotificationDialog.show(
                        context,
                        message: 'No Notification Yet',
                        icon: Icons.notifications_outlined,
                        iconColor: AppColors.textPrimary(context),
                        iconBackgroundColor: AppColors.appBackground(context),
                      );
                    },
                    child: Container(
                      height: 20,
                      width: 20,
                      // color: Colors.red,
                      child: SvgPicture.asset('assets/images/home/notification.svg', color: AppColors.textPrimary(context)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
