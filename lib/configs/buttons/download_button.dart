import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';

class DownloadOptionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const DownloadOptionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: screenWidth*0.9,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: borderColor != null
              ? Border.all(color: borderColor!)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor,size: 20,),
           SizedboxSpaccing.width03(context),
            Flexible(
              child: Text(
                label,
                style:AppTextStyles.poppins16(context,weight: FontWeight.w600,color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
