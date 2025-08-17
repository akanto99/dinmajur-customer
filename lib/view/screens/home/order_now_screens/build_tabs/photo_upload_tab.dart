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
  final Function(List<Map<String, dynamic>>)? onPhotosChanged;
  final List<Map<String, dynamic>>? initialPhotos;

  const PhotoUploadTab({
    Key? key,
    this.onPhotosChanged,
    this.initialPhotos,
  }) : super(key: key);

  @override
  State<PhotoUploadTab> createState() => _PhotoUploadTabState();
}

class _PhotoUploadTabState extends State<PhotoUploadTab> {
  List<SelectedImage> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _initializeWithExistingPhotos();
  }

  void _initializeWithExistingPhotos() {
    if (widget.initialPhotos != null && widget.initialPhotos!.isNotEmpty) {
      _selectedImages = widget.initialPhotos!.map((photoData) {
        return SelectedImage(
          imageData: photoData['imageData'] as Uint8List,
          name: photoData['name'] as String,
          timestamp: photoData['timestamp'] as DateTime,
        );
      }).toList();
    }
  }

  void _addImage(Uint8List imageData) {
    setState(() {
      _selectedImages.add(SelectedImage(
        imageData: imageData,
        name: "Bazaar List ${_selectedImages.length + 1}",
        timestamp: DateTime.now(),
      ));
    });
    _updateParent();
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    _updateParent();
  }

  void _updateParent() {
    if (widget.onPhotosChanged != null) {
      List<Map<String, dynamic>> photoData = _selectedImages.map((image) => {
        'name': image.name,
        'imageData': image.imageData,
        'timestamp': image.timestamp,
        'size': image.imageData.length,
      }).toList();

      widget.onPhotosChanged!(photoData);
    }
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
        if (_selectedImages.isNotEmpty) _buildPhotoListSection(screenWidth, screenHeight),
      ],
    );
  }

  Widget _buildUploadSection(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        border: Border(
          top: BorderSide.none,
          right: BorderSide(width: 1, color: AppColors.border(context)),
          left: BorderSide(width: 1, color: AppColors.border(context)),
          bottom: BorderSide(width: 1, color: AppColors.border(context)),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
      child: Column(
        children: [
          SizedboxSpaccing.height02(context),
          Container(
            height: 200,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              color: AppColors.textFieldFill(context),
              borderRadius: BorderRadius.circular(16),
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
          SizedboxSpaccing.height02(context),
        ],
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
          borderRadius: BorderRadius.circular(8),
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
    return Column(
      children: [
        SizedboxSpaccing.height02(context),
        Container(
          width: screenWidth * 0.9,
          color: AppColors.containerBackground(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Uploaded Photos (${_selectedImages.length})",
                style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
              ),
              SizedboxSpaccing.height012(context),
              // Use ListView.separated with shrinkWrap instead of fixed height container
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedImages.length,
                separatorBuilder: (context, index) => SizedBox(height: screenHeight * 0.01),
                itemBuilder: (context, index) => _buildPhotoListItem(index, screenHeight),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoListItem(int index, double screenHeight) {
    final image = _selectedImages[index];

    return Container(
      padding: EdgeInsets.all(screenHeight * 0.01),
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