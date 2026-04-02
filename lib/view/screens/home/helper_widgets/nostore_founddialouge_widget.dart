import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';

class NoStoresFoundDialog extends StatefulWidget {
  const NoStoresFoundDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(context: context, barrierDismissible: true,
        barrierColor: AppColors.showDialougeBackground(context),
        builder: (_) => const NoStoresFoundDialog());
  }

  @override
  State<NoStoresFoundDialog> createState() => _NoStoresFoundDialogState();
}

class _NoStoresFoundDialogState extends State<NoStoresFoundDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: AppColors.containerBackground(context),
      insetPadding: EdgeInsets.all(screenHeight * 0.02),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(color: AppColors.appBackground(context), shape: BoxShape.circle),
              child: Icon(Icons.store_mall_directory_outlined, color: AppColors.textPrimary(context), size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'No Stores Found',
              style: AppTextStyles.textSize16(context, weight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sorry, no stores are available in your area right now.',
              style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
