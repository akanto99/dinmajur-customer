import 'dart:typed_data';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerOnly {
  static final ImagePicker _imagePicker = ImagePicker();

  // Pick image from gallery only (no cropping)
  static Future<void> pickImage({
    required BuildContext context,
    Function(Uint8List)? onImagePicked, // Callback function for when image is picked
  }) async {
    XFile? pickedImage = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;

    Uint8List imageData = await pickedImage.readAsBytes();
    String imageName = pickedImage.name;
    String imageExtension = imageName.split('.').last;
    String shortenedName = imageName.length > 15
        ? imageName.substring(0, 15) + "..." + imageExtension
        : imageName;

    // Call the callback function with image data
    if (onImagePicked != null) {
      onImagePicked(imageData);
    }
  }

  // Pick image with source selection dialog (no cropping)
  static Future<void> pickImageWithSourceSelection({
    required BuildContext context,
    Function(Uint8List)? onImagePicked,
  }) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015),
        decoration: BoxDecoration(
            color: AppColors.appBackground(context),
            borderRadius: BorderRadius.circular(15)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Select Image Source',
                style: AppTextStyles.textSize16(context, weight: FontWeight.w600)
            ),
            SizedboxSpaccing.height015(context),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                  child: Column(
                    children: [
                      Icon(Icons.camera_alt, size: 40, color: AppColors.textPrimary(context)),
                      SizedboxSpaccing.height005(context),
                      Text('Camera'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                  child: Column(
                    children: [
                      Icon(Icons.photo_library, size: 40, color: AppColors.textPrimary(context)),
                      SizedboxSpaccing.height005(context),
                      Text('Gallery'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    XFile? pickedImage = await _imagePicker.pickImage(source: source);
    if (pickedImage == null) return;

    Uint8List imageData = await pickedImage.readAsBytes();
    String imageName = pickedImage.name;
    String imageExtension = imageName.split('.').last;
    String shortenedName = imageName.length > 15
        ? imageName.substring(0, 15) + "..." + imageExtension
        : imageName;

    // Call the callback function with image data
    if (onImagePicked != null) {
      onImagePicked(imageData);
    }
  }
}