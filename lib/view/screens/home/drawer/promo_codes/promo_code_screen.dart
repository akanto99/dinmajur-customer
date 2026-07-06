import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:flutter/material.dart';

class PromoCodeScreen extends StatefulWidget {
  const PromoCodeScreen({super.key});

  @override
  State<PromoCodeScreen> createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen> {
  final TextEditingController _promoController = TextEditingController();
  bool _promoError = false;

  // Sample promo codes data - Replace with your actual data source
  final List<PromoCode> _availablePromos = [
    PromoCode(
      code: 'SAVE20',
      discount: '20% off',
      description: 'Get 20% off on your next order over \$50.',
      restrictions: 'Cannot be combined with other offers.',
      expiryDate: '2025-11-30',
      isExpired: false,
      discountPercentage: 20,
      minimumAmount: 50,
    ),
    PromoCode(
      code: 'SAVE20',
      discount: '20% off',
      description: 'Get 20% off on your next order over \$50.',
      restrictions: 'Cannot be combined with other offers.',
      expiryDate: '2025-11-30',
      isExpired: true,
      discountPercentage: 20,
      minimumAmount: 50,
    ),
  ];

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromoCode() {
    String enteredCode = _promoController.text.trim().toUpperCase();

    if (enteredCode.isEmpty) {
      setState(() => _promoError = true);
      return;
    }
    setState(() => _promoError = false);

    // Check if promo code exists and is valid
    PromoCode? foundPromo = _availablePromos.firstWhere(
      (promo) => promo.code == enteredCode && !promo.isExpired,
      orElse: () => PromoCode(code: '', discount: '', description: '', restrictions: '', expiryDate: '', isExpired: true, discountPercentage: 0, minimumAmount: 0),
    );

    if (foundPromo.code.isEmpty) {
      _showMessage('Invalid or expired promo code', isError: true);
    } else {
      _showMessage('Promo code applied successfully!', isError: false);
      // TODO: Apply promo code logic here
      // Navigator.pop(context, foundPromo);
    }
  }

  void _applyPromoFromList(PromoCode promo) {
    if (promo.isExpired) {
      _showMessage('This promo code has expired', isError: true);
      return;
    }

    _promoController.text = promo.code;
    _showMessage('Promo code "${promo.code}" applied!', isError: false);
    // TODO: Apply promo code logic here
    // Navigator.pop(context, promo);
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : AppColors.button(context), duration: Duration(seconds: 2)));
  }

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
          child: AppBarHeader("Promo Code"),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedboxSpaccing.height025(context),

                  // Promo Code Input Section
                  _buildPromoInputSection(screenWidth, screenHeight),

                  SizedboxSpaccing.height03(context),

                  // Available Promos Section
                  _buildAvailablePromosSection(screenWidth, screenHeight),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoInputSection(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter Promo Code', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
          SizedboxSpaccing.height012(context),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.textFieldFill(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _promoError ? Colors.red : AppColors.border(context), width: _promoError ? 1.5 : 1.0),
                      ),
                      child: TextFormField(
                        controller: _promoController,
                        textCapitalization: TextCapitalization.characters,
                        style: AppTextStyles.textSize16(context, weight: FontWeight.w500),
                        onChanged: (v) { if (v.isNotEmpty && _promoError) setState(() => _promoError = false); },
                        decoration: InputDecoration(
                          hintText: 'e.g. SUMMER25',
                          hintStyle: AppTextStyles.textSize14(context, color: AppColors.subtitle(context), weight: FontWeight.w400),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    if (_promoError)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 2),
                        child: Text('Please enter a promo code', style: AppTextStyles.textSize12(context, color: Colors.red)),
                      ),
                  ],
                ),
              ),
              SizedboxSpaccing.width03(context),
              GestureDetector(
                onTap: _applyPromoCode,
                child: Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(color: AppColors.textPrimary(context), borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Text(
                      'Apply',
                      style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.whiteColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailablePromosSection(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Available Promos', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
            Text(
              ' (${_availablePromos.where((p) => !p.isExpired).length})',
              style: AppTextStyles.textSize18(context, weight: FontWeight.w600, color: AppColors.textPrimary(context)),
            ),
          ],
        ),
        SizedboxSpaccing.height01(context),
        Divider(height: 1, color: AppColors.border(context)),
        SizedboxSpaccing.height02(context),

        // Promo Cards
        ..._availablePromos
            .map(
              (promo) => Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                child: _buildPromoCard(promo, screenWidth, screenHeight),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildPromoCard(PromoCode promo, double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        // border: Border.all(color: promo.isExpired ? AppColors.border(context) : Color(0xFF3B82F6).withOpacity(0.3), width: 1),
        border: Border.all(color:  AppColors.border(context), width: 1),
      ),
      child: Column(
        children: [
          // Promo Header
          Container(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  promo.code,
                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.textPrimary(context)),
                ),

                // Discount Badge
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //   decoration: BoxDecoration(color: promo.isExpired ? Colors.grey.withOpacity(0.2) : Color(0xFF3B82F6), borderRadius: BorderRadius.circular(4)),
                //   child: Text(
                //     promo.discount,
                //     style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: promo.isExpired ? Colors.grey : AppColors.whiteColor),
                //   ),
                // ),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: AppColors.textPrimary(context)),
                    SizedboxSpaccing.width02(context),
                    Text(
                      'Expires: ${promo.expiryDate}',
                      style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context), weight: FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Promo Details
          Container(
            padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Description
                Text(promo.description, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),

                // Restrictions
                Text(promo.restrictions, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                SizedboxSpaccing.height015(context),

                // Action Button
                GestureDetector(
                  onTap: promo.isExpired ? null : () => _applyPromoFromList(promo),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.textFieldFill(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 1, color: AppColors.border(context)),
                    ),
                    child: Center(
                      child: Text(
                        promo.isExpired ? 'Expired' : 'Apply Code',
                        style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: promo.isExpired ? AppColors.subtitle(context) : AppColors.textPrimary(context)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedboxSpaccing.height02(context),
        ],
      ),
    );
  }
}

// Promo Code Model
class PromoCode {
  final String code;
  final String discount;
  final String description;
  final String restrictions;
  final String expiryDate;
  final bool isExpired;
  final double discountPercentage;
  final double minimumAmount;

  PromoCode({
    required this.code,
    required this.discount,
    required this.description,
    required this.restrictions,
    required this.expiryDate,
    required this.isExpired,
    required this.discountPercentage,
    required this.minimumAmount,
  });
}
