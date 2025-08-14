import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/components/image_picker/image_picker_only.dart';
import 'package:dinmajur_customer/configs/res/components/full_screen_image/full_screen_image_2.dart';

class SelectedImage {
  final Uint8List imageData;
  final String name;
  final DateTime timestamp;

  SelectedImage({
    required this.imageData,
    required this.name,
    required this.timestamp,
  });
}

class PhotoUploadTab extends StatefulWidget {
  const PhotoUploadTab({Key? key}) : super(key: key);

  @override
  State<PhotoUploadTab> createState() => _PhotoUploadTabState();
}

class _PhotoUploadTabState extends State<PhotoUploadTab> {
  List<SelectedImage> _selectedImages = [];

  void _addImage(Uint8List imageData) {
    setState(() {
      _selectedImages.add(SelectedImage(
        imageData: imageData,
        name: "Bazaar List ${_selectedImages.length + 1}",
        timestamp: DateTime.now(),
      ));
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _openImagePicker() {
    ImagePickerOnly.pickImageWithSourceSelection(
      context: context,
      onImagePicked: _addImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        _buildUploadSection(screenWidth, screenHeight),
        SizedboxSpaccing.height02(context),
        _buildPhotoListSection(screenWidth, screenHeight),
      ],
    );
  }

  Widget _buildUploadSection(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.9,
      color: AppColors.containerBackground(context),
      child: Padding(
        padding: EdgeInsets.only(
          left: screenHeight * 0.02,
          right: screenHeight * 0.02,
          bottom: screenHeight * 0.02,
        ),
        child: Container(
          height: 195,
          padding: EdgeInsets.all(screenHeight * 0.02),
          decoration: BoxDecoration(
            color: AppColors.textFieldFill(context),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 1, color: AppColors.border(context)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.photo_camera, size: 35, color: Colors.grey),
              SizedboxSpaccing.height01(context),
              Text(
                "Take a photo of your bazaar list or\nupload from gallery",
                style: AppTextStyles.textSize14(context, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedboxSpaccing.height02(context),
              _buildUploadButton(screenHeight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton(double screenHeight) {
    return GestureDetector(
      onTap: _openImagePicker,
      child: Container(
        width: screenHeight * 0.3,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.button(context),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FontAwesomeIcons.upload, color: Colors.white, size: 20),
            SizedboxSpaccing.width02(context),
            Text(
              "Upload Bazaar List",
              style: AppTextStyles.textSize16(
                context,
                color: Colors.white,
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoListSection(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.9,
      color: AppColors.containerBackground(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedImages.isNotEmpty) ...[
            _buildPhotoListHeader(screenHeight),
            _buildPhotoList(screenHeight),
            SizedboxSpaccing.height02(context),
          ] else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildPhotoListHeader(double screenHeight) {
    return Padding(
      padding: EdgeInsets.all(screenHeight * 0.02),
      child: Text(
        "Uploaded Photos (${_selectedImages.length})",
        style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPhotoList(double screenHeight) {
    return Container(
      height: 200,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) => _buildPhotoListItem(index, screenHeight),
      ),
    );
  }

  Widget _buildPhotoListItem(int index, double screenHeight) {
    final image = _selectedImages[index];

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      padding: EdgeInsets.all(screenHeight * 0.015),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          _buildImageThumbnail(image),
          SizedboxSpaccing.width02(context),
          _buildImageDetails(image),
          _buildImageActions(image, index),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(SelectedImage image) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Image.memory(image.imageData, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildImageDetails(SelectedImage image) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            image.name,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            "${_formatTimestamp(image.timestamp)} • ${_formatFileSize(image.imageData.length)}",
            style: AppTextStyles.textSize12(context, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildImageActions(SelectedImage image, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _viewImage(image),
          icon: Icon(
            Icons.visibility,
            color: AppColors.textPrimary(context),
            size: 20,
          ),
        ),
        IconButton(
          onPressed: () => _removeImage(index),
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 100,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              "No photos uploaded yet",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _viewImage(SelectedImage image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage2(
          imageData: image.imageData,
          imageName: image.name,
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return "${bytes}B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)}KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB";
  }
}