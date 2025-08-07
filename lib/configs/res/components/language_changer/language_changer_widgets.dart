import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:slide_switcher/slide_switcher.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/provider/language_change_provider/language_change_provider.dart';

class LanguageSlideSwitcher extends StatefulWidget {
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;
  final Duration? animationDuration;

  const LanguageSlideSwitcher({Key? key, this.width, this.height, this.backgroundColor, this.activeColor, this.inactiveColor, this.textStyle, this.borderRadius, this.animationDuration})
    : super(key: key);

  @override
  State<LanguageSlideSwitcher> createState() => _LanguageSlideSwitcherState();
}

class _LanguageSlideSwitcherState extends State<LanguageSlideSwitcher> {
  int? _currentIndex;

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageChangeProvider>(
      builder: (context, languageProvider, child) {
        // Get current language index (0 for English, 1 for Bengali)
        int currentIndex = languageProvider.appLocale?.languageCode == 'bn' ? 1 : 0;

        // Debug print
        print('SlideSwitcher - Current language: ${languageProvider.appLocale?.languageCode}, Index: $currentIndex');

        // Update _currentIndex if it's different
        if (_currentIndex != currentIndex) {
          _currentIndex = currentIndex;
        }

        return SlideSwitcher(
          slidersColors: [
            AppColors.button(context)
          ],
          containerBorder:  Border.all(color: AppColors.border(context)),
          onSelect: (index) {
            _handleLanguageChange(context, index, languageProvider);
          },
          containerHeight:30,
          containerWight:  80,
          indents: 3,
          containerColor: AppColors.textFieldFill(context),
          direction: Axis.horizontal,
          initialIndex: currentIndex,
          key: ValueKey(currentIndex),
          children: [
            // English Option
            Container(
              child: Center(
                child: Text(
                  'Eng',
                  style:
                  widget.textStyle?.copyWith(color: currentIndex == 0 ? (widget.activeColor ?? Colors.white) : (widget.inactiveColor ?? AppColors.textPrimary(context))) ??
                      AppTextStyles.textSize14(context, color: currentIndex == 0 ? (widget.activeColor ?? Colors.white) : (widget.inactiveColor ?? AppColors.textPrimary(context))
                      ),
                ),
              ),
            ),
            // Bengali Option
            Container(
              child:   Center(
                child: Text(
                  'Bn',
                  style:
                  widget.textStyle?.copyWith(color: currentIndex == 1 ? (widget.activeColor ?? Colors.white) : (widget.inactiveColor ?? AppColors.textPrimary(context))) ??
                      GoogleFonts.hindSiliguri(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: currentIndex == 1 ? (widget.activeColor ?? Colors.white) : (widget.inactiveColor ?? AppColors.textPrimary(context)),
                      ),
                ),
              ),
            ),
          ],

        );
      },
    );
  }

  void _handleLanguageChange(BuildContext context, int index, LanguageChangeProvider languageProvider) async {
    if (index == 0) {
      await languageProvider.changeLanguage(Locale('en'));
    } else if (index == 1) {
      await languageProvider.changeLanguage(Locale('bn'));
    }

    // Update local state
    setState(() {
      _currentIndex = index;
    });

    // Optional: Show a brief feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(index == 0 ? 'Language changed to English' : 'ভাষা বাংলায় পরিবর্তিত হয়েছে', style: GoogleFonts.poppins(fontSize: 14)),
        duration: Duration(seconds: 1),
        backgroundColor: AppColors.textPrimary(context),
      ),
    );
  }
}
