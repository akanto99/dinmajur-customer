import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';

class NotificationDialog {
  static void show(BuildContext context, {
    String? message,
    IconData? icon,
    Color? iconColor,
    Color? iconBackgroundColor,
    double? iconSize,
    VoidCallback? onClose,
    bool barrierDismissible = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width * 1;
        final screenHeight = MediaQuery.of(context).size.height * 1;
        return Dialog(
          backgroundColor: iconBackgroundColor,
          insetPadding: EdgeInsets.all(100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedboxSpaccing.height005(context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        if (onClose != null) onClose();
                      },
                      child: Icon(
                        Icons.close,
                        color:AppColors.textPrimary(context),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                SizedboxSpaccing.height01(context),

                // Icon
                Icon(
                  icon ?? Icons.notifications_outlined,
                  size: iconSize ?? 30,
                  color: iconColor ?? Colors.grey[400],
                ),

                SizedboxSpaccing.height01(context),
                // Message
                Text(
                  message ?? 'No Notification Yet',
                  style: AppTextStyles.poppins16(context,weight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),

                SizedboxSpaccing.height005(context),
              ],
            ),
          ),
        );
      },
    );
  }
}