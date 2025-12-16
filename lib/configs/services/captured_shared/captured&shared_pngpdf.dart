import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:device_info_plus/device_info_plus.dart';

class ScreenshotHandler {
  // Helper function to resize image bytes to given width and height
  static Future<Uint8List> resizeImage(
      Uint8List data,
      int width,
      int height,
      ) async {
    final codec = await ui.instantiateImageCodec(
      data,
      targetWidth: width,
      targetHeight: height,
    );
    final frame = await codec.getNextFrame();
    final resizedImage = frame.image;
    final byteData = await resizedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  // Get Android version
  static Future<int> getAndroidVersion() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    } catch (e) {
      return 0;
    }
  }

  // Request appropriate permissions based on Android version
  static Future<bool> requestPermissions() async {
    int androidVersion = await getAndroidVersion();

    if (androidVersion >= 33) { // Android 13+
      // For Android 13+, request photo permission instead of storage
      final photoStatus = await Permission.photos.request();
      if (photoStatus.isGranted) {
        return true;
      }

      // If photo permission denied, try manage external storage (requires special permission)
      final manageStorageStatus = await Permission.manageExternalStorage.request();
      if (manageStorageStatus.isGranted) {
        return true;
      }

      return false;
    } else if (androidVersion >= 30) { // Android 11+
      // For Android 11-12, try manage external storage first
      final manageStorageStatus = await Permission.manageExternalStorage.request();
      if (manageStorageStatus.isGranted) {
        return true;
      }

      // Fallback to regular storage permission
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } else {
      // For older Android versions
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }
  }

  // Get appropriate download directory based on Android version
  static Future<Directory> getDownloadDirectory() async {
    int androidVersion = await getAndroidVersion();

    if (androidVersion >= 30) { // Android 11+
      // Use app-specific external directory for Android 11+
      final appDocDir = await getExternalStorageDirectory();
      if (appDocDir != null) {
        final downloadDir = Directory('${appDocDir.path}/Downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir;
      }
    }

    // Fallback to Downloads directory (may not work on newer Android versions)
    try {
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        return downloadDir;
      }
    } catch (e) {
      // If access denied, fall back to app directory
    }

    // Final fallback - use app documents directory
    final appDocDir = await getApplicationDocumentsDirectory();
    return appDocDir;
  }

  // Enhanced function to handle PNG, PDF, and Share
  static Future<void> captureAndHandleCard({
    required BuildContext context,
    required GlobalKey globalKey,
    required bool isShare,
    bool isPdf = false,
  }) async {
    bool isSuccess = false;
    String? errorMsg;
    File? savedFile;

    // Show loading dialog with appropriate message
    String loadingMessage = isShare
        ? 'শেয়ার করা হচ্ছে...'
        : isPdf
        ? 'PDF তৈরি করা হচ্ছে...'
        : 'ছবি সেভ করা হচ্ছে...';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.containerBackground(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Row(
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.button(context),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  loadingMessage,
                  style: AppTextStyles.textSize12(
                    color: AppColors.subtitle(context),
                    context,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    try {
      // Request appropriate permissions
      bool hasPermission = await requestPermissions();

      if (!hasPermission) {
        await openAppSettings();
        errorMsg = "Storage permission denied. Please enable storage access in settings.";
      } else {
        RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
        ///Pixel Perfectness
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        // Define directory to save or share
        final directory = isShare
            ? await getTemporaryDirectory()
            : Directory('/storage/emulated/0/Download');

        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        if (isPdf) {
          // Generate PDF
          savedFile = await _generatePDF(pngBytes, directory.path);
        } else {
          // Resize captured image to 1050x600 px for PNG
          Uint8List resizedBytes = await resizeImage(pngBytes, 1040, 650);

          final filePath =
              '${directory.path}/card_${DateTime.now().millisecondsSinceEpoch}.png';
          File file = File(filePath);
          await file.writeAsBytes(resizedBytes);
          savedFile = file;
        }

        isSuccess = true;
      }
    } catch (e) {
      errorMsg = "Error processing: $e";
      print("Screenshot error: $e"); // For debugging
    }

    Navigator.of(context).pop(); // Close loading dialog

    // Show success dialog or share file
    if (isSuccess && savedFile != null) {
      if (isShare) {
        await Share.shareXFiles([
          XFile(savedFile.path),
        ], text: 'আমার বিজনেস কার্ড দেখুন!');
      } else {
        int androidVersion = await getAndroidVersion();
        String locationInfo = androidVersion >= 30
            ? "অ্যাপের ফোল্ডারে"
            : "ডাউনলোড ফোল্ডারে";

        String successMessage = isPdf
            ? "PDF সফলভাবে $locationInfo সেভ হয়েছে"
            : "ছবি সফলভাবে $locationInfo সেভ হয়েছে";

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.containerBackground(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  "সফল!",
                  style: AppTextStyles.textSize14(
                    context,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  successMessage,
                  style: AppTextStyles.textSize12(
                    color: AppColors.subtitle(context),
                    context,
                    weight: FontWeight.w500,
                  ),
                ),
                if (androidVersion >= 30) ...[
                  SizedBox(height: 8),
                  Text(
                    "File location_screens: ${savedFile?.path}",
                    style: AppTextStyles.textSize12(
                      color: AppColors.subtitle(context),
                      context,
                      weight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "ঠিক আছে",
                  style: AppTextStyles.textSize12(
                    color: AppColors.subtitle(context),
                    context,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg ?? "অজানা ত্রুটি ঘটেছে",
            style: AppTextStyles.textSize12(
              color: AppColors.subtitle(context),
              context,
              weight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // Generate PDF from image bytes
  static Future<File> _generatePDF(Uint8List imageBytes, String directoryPath) async {
    final pdf = pw.Document();

    // Create PDF page with the business card image
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300, width: 1),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Image(
                pw.MemoryImage(imageBytes),
                fit: pw.BoxFit.contain,
                width: 500,
                height: 300,
              ),
            ),
          );
        },
      ),
    );

    // Save PDF file
    final filePath = '$directoryPath/business_card_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}