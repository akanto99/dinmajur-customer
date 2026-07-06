import 'dart:typed_data';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FullScreenImage2 extends StatefulWidget {
  final Uint8List imageData;  // Changed from String imageUrl
  final String imageName;     // Added image name for title

  FullScreenImage2({
    required this.imageData,   // Updated constructor
    required this.imageName,
  });

  @override
  State<FullScreenImage2> createState() => _FullScreenImage2State();
}

class _FullScreenImage2State extends State<FullScreenImage2> {
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
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return Container(
      height: screenHeight,
      child: Column(
        children: [
          // Header with back button and title
          Container(
            width: screenWidth,
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: AppColors.border(context), width: 1.0)
              ),
            ),
            child: Center(
              child: Container(
                height: 60,
                width: screenWidth * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary(context),
                        size: 22,
                      ),
                    ),
                    // Add title in the middle
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.imageName,
                          style: AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, RoutesName.navigationBar);
                      },
                      child: Icon(
                        Icons.home,
                        color: AppColors.textPrimary(context),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Image display area
          Expanded(
            child: Center(
              child: Container(
                height: screenHeight * 0.81,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Hero(
                      tag: 'imageHero',
                      child: InteractiveViewer(  // Added for zoom/pan functionality
                        child: Image.memory(     // Changed from Image.network to Image.memory
                          widget.imageData,      // Use the Uint8List data
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 50,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Failed to load image',
                                  style: AppTextStyles.textSize16(context, color: AppColors.textPrimary(context)),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}