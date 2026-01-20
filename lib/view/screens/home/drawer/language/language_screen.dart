import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/provider/language_change_provider/language_change_provider.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(mobile: body(), desktop: body(), tablet: body()),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)));
          },
          child: AppBarHeader(AppLocalizations.of(context)!.language),
        ),
        Expanded(
          child: Consumer<LanguageChangeProvider>(
            builder: (context, languageProvider, child) {
              _selectedLanguage = languageProvider.appLocale?.languageCode ?? 'en';

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.chooseYourLanguage,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.textSize24(context, weight: FontWeight.w600),
                    ),

                    SizedboxSpaccing.height02(context),

                    Text(
                      AppLocalizations.of(context)!.selectLanguageDesc,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w400),
                    ),
                    SizedboxSpaccing.height04(context),

                    // English Option
                    _buildLanguageCard(
                      context: context,
                      languageCode: 'en',
                      languageName: 'English',
                      nativeName: 'ইংরেজি',
                      flag: '🇬🇧',
                      isSelected: _selectedLanguage == 'en',
                      onTap: () => _handleLanguageChange(context, 'en', languageProvider),
                    ),
                    SizedboxSpaccing.height02(context),

                    // Bengali Option
                    _buildLanguageCard(
                      context: context,
                      languageCode: 'bn',
                      languageName: 'Bengali',
                      nativeName: 'বাংলা',
                      flag: '🇧🇩',
                      isSelected: _selectedLanguage == 'bn',
                      onTap: () => _handleLanguageChange(context, 'bn', languageProvider),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard({
    required BuildContext context,
    required String languageCode,
    required String languageName,
    required String nativeName,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.button(context).withOpacity(0.1) : AppColors.textFieldFill(context),
          border: Border.all(color: isSelected ? AppColors.button(context) : AppColors.border(context), width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Flag/Icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Center(child: Text(flag, style: TextStyle(fontSize: 18))),
            ),
            SizedBox(width: 16),

            // Language Names
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageName,
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context)),
                  ),
                  SizedBox(height: 2),
                  Text(
                    nativeName,
                    style: languageCode == 'bn'
                        ? GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary(context).withOpacity(0.7))
                        : GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary(context).withOpacity(0.7)),
                  ),
                ],
              ),
            ),

            // Checkmark
            AnimatedScale(
              scale: isSelected ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
                child: Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLanguageChange(BuildContext context, String languageCode, LanguageChangeProvider languageProvider) async {
    if (_selectedLanguage != languageCode) {
      await languageProvider.changeLanguage(Locale(languageCode));

      setState(() {
        _selectedLanguage = languageCode;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageCode == 'en' ? 'Language changed to English' : 'ভাষা বাংলায় পরিবর্তিত হয়েছে',
            style: languageCode == 'en' ? GoogleFonts.poppins(fontSize: 14,color: AppColors.whiteColor) : GoogleFonts.hindSiliguri(fontSize: 14,color: AppColors.whiteColor),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.button(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }
}
