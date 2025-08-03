// // Updated ImagePickerNoPrefs.dart
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:dinmajur/configs/res/color.dart';
// import 'package:dinmajur/configs/res/sizedbox_spaccing.dart';
// import 'package:dinmajur/configs/res/text_styles.dart';
// import 'package:flutter/material.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ImagePickerNoPrefs {
//   static final ImagePicker _imagePicker = ImagePicker();
//
//   static Future<void> pickImage({
//     required BuildContext context,
//     Function(Uint8List)? onImageCropped, // Callback function for when image is cropped
//   }) async {
//     XFile? pickedImage = await _imagePicker.pickImage(source: ImageSource.gallery);
//     if (pickedImage == null) return;
//
//     final croppedFile = await ImageCropper().cropImage(
//       sourcePath: pickedImage.path,
//       compressFormat: ImageCompressFormat.jpg,
//       compressQuality: 90,
//       maxWidth: 400,
//       maxHeight: 400,
//       aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
//       uiSettings: [
//         AndroidUiSettings(
//           toolbarColor: AppColors.button(context),
//           toolbarWidgetColor: Colors.white,
//           initAspectRatio: CropAspectRatioPreset.square,
//           lockAspectRatio: true,
//           toolbarTitle: "Crop Image",
//           statusBarColor: AppColors.button(context),
//           activeControlsWidgetColor: AppColors.button(context),
//         ),
//         IOSUiSettings(
//           aspectRatioLockEnabled: true,
//           aspectRatioPickerButtonHidden: true,
//           title: "Crop Image",
//           doneButtonTitle: "Done",
//           cancelButtonTitle: "Cancel",
//         ),
//       ],
//     );
//
//     // This will be called when user clicks the crop tick/done button
//     if (croppedFile != null) {
//       Uint8List imageData = await croppedFile.readAsBytes();
//       String imageName = pickedImage.name;
//       String imageExtension = imageName.split('.').last;
//       String shortenedName = imageName.length > 15
//           ? imageName.substring(0, 15) + "..." + imageExtension
//           : imageName;
//
//       // Save to SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('image', base64Encode(imageData));
//       await prefs.setString('imageName', shortenedName);
//
//       // Call the callback function to trigger API call
//       if (onImageCropped != null) {
//         onImageCropped(imageData);
//       }
//     }
//   }
//
//   // Alternative method with source selection dialog
//   static Future<void> pickImageWithSourceSelection({
//     required BuildContext context,
//     Function(Uint8List)? onImageCropped,
//   }) async {
//     final ImageSource? source = await showModalBottomSheet<ImageSource>(
//       context: context,
//       builder: (context) => Container(
//         padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015),
//
//         decoration: BoxDecoration(
//             color: AppColors.appBackground(context),
//           borderRadius: BorderRadius.circular(15)
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Select Image Source',
//               style: AppTextStyles.siliguri16OrAppBar(context,weight: FontWeight.w600)
//             ),
//             SizedboxSpaccing.height015(context),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context, ImageSource.camera),
//                   child: Column(
//                     children: [
//                       Icon(Icons.camera_alt, size: 40,color: AppColors.textPrimary(context),),
//                       SizedboxSpaccing.height005(context),
//                       Text('Camera'),
//                     ],
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context, ImageSource.gallery),
//                   child: Column(
//                     children: [
//                       Icon(Icons.photo_library,size: 40,color: AppColors.textPrimary(context)),
//                       SizedboxSpaccing.height005(context),
//                       Text('Gallery'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//
//     if (source == null) return;
//
//     XFile? pickedImage = await _imagePicker.pickImage(source: source);
//     if (pickedImage == null) return;
//
//     final croppedFile = await ImageCropper().cropImage(
//       sourcePath: pickedImage.path,
//       compressFormat: ImageCompressFormat.jpg,
//       compressQuality: 90,
//       maxWidth: 400,
//       maxHeight: 400,
//       aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
//       uiSettings: [
//         AndroidUiSettings(
//           toolbarColor: AppColors.button(context),
//           toolbarWidgetColor: Colors.white,
//           initAspectRatio: CropAspectRatioPreset.square,
//           lockAspectRatio: true,
//           toolbarTitle: "Crop Image",
//           statusBarColor: AppColors.button(context),
//           activeControlsWidgetColor: AppColors.button(context),
//         ),
//         IOSUiSettings(
//           aspectRatioLockEnabled: true,
//           aspectRatioPickerButtonHidden: true,
//           title: "Crop Image",
//           doneButtonTitle: "Done",
//           cancelButtonTitle: "Cancel",
//         ),
//       ],
//     );
//
//     if (croppedFile != null) {
//       Uint8List imageData = await croppedFile.readAsBytes();
//       String imageName = pickedImage.name;
//       String imageExtension = imageName.split('.').last;
//       String shortenedName = imageName.length > 15
//           ? imageName.substring(0, 15) + "..." + imageExtension
//           : imageName;
//
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('image', base64Encode(imageData));
//       await prefs.setString('imageName', shortenedName);
//
//       if (onImageCropped != null) {
//         onImageCropped(imageData);
//       }
//     }
//   }
// }