import 'dart:convert';
import 'dart:typed_data';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crop_your_image/crop_your_image.dart';

enum ImageType {
  profilePicture,
  coverPhoto,
}

class DynamicImagePicker {
  static const int maxFileSizeInBytes = 5 * 1024 * 1024;
  static final ImagePicker _imagePicker = ImagePicker();

  static Map<String, String> _getPreferenceKeys(ImageType imageType) {
    switch (imageType) {
      case ImageType.profilePicture:
        return {
          'image': 'ProfilePicture_image',
          'imageName': 'profile_picture_name',
          'displayName': 'profile_picture_display',
        };
      case ImageType.coverPhoto:
        return {
          'image': 'CoverPhoto_image',
          'imageName': 'cover_photo_name',
          'displayName': 'cover_photo_display',
        };
    }
  }

  static Future<void> pickImage({
    required BuildContext context,
    required ImageType imageType,
    required Function(Uint8List? imageData, String? imageName, String? displayName) onImageSelected,
    required Function onApiCall,
  }) async {
    try {
      XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedImage == null) return;

      // int fileSize = await pickedImage.length();
      // if (fileSize > maxFileSizeInBytes) {
      //   double fileSizeInMB = fileSize / (1024 * 1024);
      //   Utils.flushBarErrorMessage(
      //       "দয়া করে ৫ এমবির কম সাইজের ছবি নির্বাচন করুন। (বর্তমান সাইজ: ${fileSizeInMB.toStringAsFixed(2)} MB)",
      //       context
      //   );
      //   return;
      // }

      Uint8List imageData = await pickedImage.readAsBytes();
      String imageName = pickedImage.name;

      if (context.mounted) {
        await _showCropDialog(
          context: context,
          imageData: imageData,
          imageName: imageName,
          imageType: imageType,
          onImageSelected: onImageSelected,
          onApiCall: onApiCall,
        );
      }
    } catch (e) {
      Utils.flushBarErrorMessage("ছবি নির্বাচনে সমস্যা হয়েছে", context);
    }
  }

  static Future<void> _showCropDialog({
    required BuildContext context,
    required Uint8List imageData,
    required String imageName,
    required ImageType imageType,
    required Function(Uint8List? imageData, String? imageName, String? displayName) onImageSelected,
    required Function onApiCall,
  }) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cropController = CropController();
    bool isCropping = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: AppColors.appBackground(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(width: 0.4, color: AppColors.button(context)),
          ),
          child: Container(
            width: screenWidth * 0.9,
            height: screenHeight * 0.6,
            child: Column(
              children: [
                Container(
                  height: screenHeight * 0.07,
                  width: screenWidth * 0.9,
                  decoration: BoxDecoration(
                    color: AppColors.button(context),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: screenWidth * 0.1,
                              alignment: Alignment.center,
                              child: Icon(Icons.close, color: Colors.white, size: 18),
                            ),
                          ),
                          SizedboxSpaccing.width03(context),
                          Text(
                            'ছবি কাটুন',
                            style: TextStyle(
                              fontFamily: "hindSiliguri",
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: isCropping ? null : () {
                          setState(() => isCropping = true);
                          cropController.crop();
                        },
                        child: Container(
                          width: screenWidth * 0.1,
                          alignment: Alignment.center,
                          child: isCropping
                              ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                              : Icon(Icons.check, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: screenWidth * 0.9,
                    padding: EdgeInsets.all(8),
                    child: Visibility(
                      visible: !isCropping,
                      replacement: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.button(context)),
                            SizedBox(height: 16),
                            Text(
                              'ছবি প্রক্রিয়া করা হচ্ছে...',
                              style: TextStyle(
                                fontFamily: "hindSiliguri",
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Crop(
                          image: imageData,
                          controller: cropController,
                          onCropped: (result) async {
                            switch (result) {
                              case CropSuccess(:final croppedImage):
                                Navigator.of(context).pop();
                                await _processCroppedImage(
                                  croppedData: croppedImage,
                                  imageName: imageName,
                                  imageType: imageType,
                                  onImageSelected: onImageSelected,
                                  onApiCall: onApiCall,
                                );
                                break;
                              case CropFailure(:final cause):
                                setState(() => isCropping = false);
                                Utils.flushBarErrorMessage("Failed to crop image", context);
                                break;
                            }
                          },
                          aspectRatio: 1.0,
                          withCircleUi: false,
                          baseColor: Colors.grey.shade200,
                          maskColor: Colors.black.withOpacity(0.6),
                          cornerDotBuilder: (size, edgeAlignment) => SizedBox.shrink(),
                          interactive: true,
                          fixCropRect: false,
                          radius: 8,
                          initialRectBuilder: InitialRectBuilder.withBuilder(
                                (viewportRect, imageRect) {
                              const double fixedCropSize = 200.0;
                              final centerX = viewportRect.center.dx;
                              final centerY = viewportRect.center.dy;
                              const halfSize = fixedCropSize / 2;
                              return Rect.fromLTRB(
                                centerX - halfSize,
                                centerY - halfSize,
                                centerX + halfSize,
                                centerY + halfSize,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _processCroppedImage({
    required Uint8List croppedData,
    required String imageName,
    required ImageType imageType,
    required Function(Uint8List? imageData, String? imageName, String? displayName) onImageSelected,
    required Function onApiCall,
  }) async {
    try {
      String actualImageName = imageName;
      String imageExtension = imageName.split('.').last.toLowerCase();
      String baseImageName = imageName.split('.').first;
      String displayName = baseImageName.length > 15
          ? '${baseImageName.substring(0, 15)}...$imageExtension'
          : imageName;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Map<String, String> prefKeys = _getPreferenceKeys(imageType);

      await prefs.setString(prefKeys['image']!, base64Encode(croppedData));
      await prefs.setString(prefKeys['imageName']!, actualImageName);
      await prefs.setString(prefKeys['displayName']!, displayName);

      onImageSelected(croppedData, actualImageName, displayName);
      onApiCall();
    } catch (e) {
    }
  }

  static Future<void> loadSavedImage({
    required ImageType imageType,
    required Function(Uint8List? imageData, String? imageName, String? displayName) onImageLoaded,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Map<String, String> prefKeys = _getPreferenceKeys(imageType);

      String? base64Image = prefs.getString(prefKeys['image']!);
      String? actualImageName = prefs.getString(prefKeys['imageName']!);
      String? displayImageName = prefs.getString(prefKeys['displayName']!);

      if (base64Image != null && base64Image.isNotEmpty) {
        Uint8List imageData = base64Decode(base64Image);
        String? finalDisplayName = displayImageName ?? actualImageName;
        onImageLoaded(imageData, actualImageName, finalDisplayName);
      } else {
        onImageLoaded(null, null, null);
      }
    } catch (e) {
      onImageLoaded(null, null, null);
    }
  }

  static Future<void> removeSavedImage(ImageType imageType) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Map<String, String> prefKeys = _getPreferenceKeys(imageType);

      await prefs.remove(prefKeys['image']!);
      await prefs.remove(prefKeys['imageName']!);
      await prefs.remove(prefKeys['displayName']!);
    } catch (e) {
    }
  }
}