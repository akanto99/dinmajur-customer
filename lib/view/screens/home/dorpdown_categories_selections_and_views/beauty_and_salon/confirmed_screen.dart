import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/components/pdf_reciept_generator_auto_open_download/get_booking_confirmation_pdf_generator.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/get_confirmedbooking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class BeautyConfirmedScreen extends StatefulWidget {
  final String trackingId;
  const BeautyConfirmedScreen({Key? key, required this.trackingId}) : super(key: key);

  @override
  State<BeautyConfirmedScreen> createState() => _BeautyConfirmedScreenState();
}

class _BeautyConfirmedScreenState extends State<BeautyConfirmedScreen> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)), (route) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.containerBackground(context),
        body: SafeArea(child: _body()),
      ),
    );
  }

  Widget _body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)), (route) => false);
          },
          child: Container(height: 60, child: AppBarHeader("Booking Confirmation")),
        ),

      ],
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context, {bool isLongText = false}) {
    return isLongText
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context), weight: FontWeight.w500)),
              SizedboxSpaccing.height01(context),
              Text(value, style: AppTextStyles.textSize12(context, weight: FontWeight.w400)),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.textSize14(context, color: AppColors.textPrimary(context), weight: FontWeight.w500)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.textSize12(context, weight: FontWeight.w400),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd-MM-yyyy').format(date);
  }
}
