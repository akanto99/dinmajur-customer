import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/notifications/resuable_notifications.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

enum ErrorType {
  network,
  timeout,
  // server,
  general
}

class ErrorStateWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final double? height;

  const ErrorStateWidget({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
    this.height,
  }) : super(key: key);

  ErrorType _getErrorType(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('timeout') ||
        lowerMessage.contains('request timeout') ||
        lowerMessage.contains('took too long')) {
      return ErrorType.timeout;
    } else if (lowerMessage.contains('no internet') ||
        lowerMessage.contains('network') ||
        lowerMessage.contains('connection') ||
        lowerMessage.contains('socket')) {
      return ErrorType.network;
    }
    // else if (lowerMessage.contains('server') ||
    //     lowerMessage.contains('500') ||
    //     lowerMessage.contains('503') ||
    //     lowerMessage.contains('502')) {
    //   return ErrorType.server;
    // }
    else {
      return ErrorType.general;
    }
  }

  Map<String, dynamic> _getErrorConfig(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.timeout:
        return {
          'icon': Icons.access_time_outlined,
          'title': 'Request Timeout',
          'description': 'The request is taking longer than expected. Please try again.',
          'color': Colors.red,
           'tips': [
            'Check your internet connection speed',
            'Try switching between WiFi and mobile data',
            'Close other apps using internet'
          ]
        };
      case ErrorType.network:
        return {
          'icon': Icons.wifi_off_rounded,
          'title': 'No Internet Connection',
          'description': 'Please check your internet connection and try again.',
          'color':Colors.red,
            'tips': [
            'Check if WiFi or mobile data is enabled',
            'Try turning airplane mode on and off',
            'Restart your router if using WiFi'
          ]
        };
      // case ErrorType.server:
      //   return {
      //     'icon': Icons.dns_rounded,
      //     'title': 'Server Error',
      //     'description': 'Our servers are having issues. Please try again later.',
      //     'color': Colors.purple[600],
      //     'backgroundColor': Colors.purple.withOpacity(0.1),
     // 'tips': [
     //        'Server maintenance may be in progress',
     //        'Try again after a few minutes',
     //        'Contact support if problem persists'
     //      ]
      //   };
      case ErrorType.general:
      default:
        return {
          'icon': Icons.error_outline_rounded,
          'title': 'Something went wrong',
          'description': 'An unexpected error occurred. Please try again.',
          'color': Colors.red[600],
           'tips': [
            'Check your internet connection',
            'Try again after a moment',
            'Restart the app if problem continues'
          ]
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final errorType = _getErrorType(errorMessage);
    final config = _getErrorConfig(errorType);

    return Container(
      height: height ?? screenHeight * 0.29,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: screenWidth,
              height: screenHeight*0.05,
              child: Center(
                child:  Icon(
                  config['icon'],
                  size: 40,
                  color: config['color'],
                ),
              ),
            ),

            SizedboxSpaccing.height01(context),
            SizedboxSpaccing.height01(context),
            Container(
              height: screenHeight*0.03,
              child: Text(
                config['title'],
                style: AppTextStyles.textSize16(
                    context,
                    weight: FontWeight.w500
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // SizedboxSpaccing.height005(context),
            // Error Description
            Text(
              config['description'],
              style: AppTextStyles.textSize12(
                  context,
                  weight: FontWeight.w400,
                color: AppColors.subtitle(context)
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            SizedboxSpaccing.height015(context),
            SizedboxSpaccing.height015(context),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                height: screenHeight * 0.045,
                width: screenWidth * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color:  AppColors.button(context),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon( Icons.refresh_rounded,
                        size: 18,
                        color: AppColors.whiteColor,
                      ),
                      SizedboxSpaccing.width02(context),
                      Text(
                        errorType == ErrorType.timeout
                            ? 'Try Again'
                            : 'Retry',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Additional info for timeout errors
            if (errorType == ErrorType.timeout) ...[
              SizedboxSpaccing.height015(context),
              SizedboxSpaccing.height015(context),
              // Tips Section (only for timeout and connection errors)
              Container(
                width: screenWidth*0.9,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.border(context),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 16,
                          color:  AppColors.textPrimary(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Troubleshooting Tips',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...config['tips'].map<Widget>((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:  AppColors.border(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tip,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary(context),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorStateEmptyHeaderWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final double? height;

  const ErrorStateEmptyHeaderWidget({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    bool isNetworkError = errorMessage.toLowerCase().contains('no internet') ||
        errorMessage.toLowerCase().contains('network') ||
        errorMessage.toLowerCase().contains('connection') ||
        errorMessage.toLowerCase().contains('timeout');

    return Container(
      // color: AppColors.blackColor,
      // width: screenWidth*0.9,
      padding: EdgeInsets.symmetric(horizontal:screenWidth * 0.04,vertical: screenHeight * 0.015),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Drawer Icon
          Builder(
            builder:
                (context) =>
                GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.appBackground(context),
                      border: Border.all(width: 1, color: AppColors.textPrimary(context)),
                    ),
                  ),
                ),
          ),
          // Right Side Icons
          Row(
            children: [
              GestureDetector(
                  onTap: (){
                    NotificationDialog.show(
                      context,
                      message: 'Empty Inbox',
                      icon: CupertinoIcons.text_bubble,
                      iconColor: AppColors.textPrimary(context),
                      iconBackgroundColor:  AppColors.appBackground(context),
                    );
                  },
                  child: Container(height: 20, width: 20, child: SvgPicture.asset('assets/images/home/email.svg', color: AppColors.textPrimary(context)))),
              SizedboxSpaccing.width02(context),
              GestureDetector(
                onTap: (){
                  NotificationDialog.show(
                    context,
                    message: 'No Notification Yet',
                    icon: Icons.notifications_outlined,
                    iconColor: AppColors.textPrimary(context),
                    iconBackgroundColor:  AppColors.appBackground(context),
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
    );
  }
}
