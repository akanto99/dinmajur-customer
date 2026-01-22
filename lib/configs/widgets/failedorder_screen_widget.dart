import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:flutter/material.dart';

class FailedOrderScreenWidget extends StatefulWidget {
  final String trackingId;
  final String valId;
  final String? reason;
  final String? errorMessage;

  const FailedOrderScreenWidget({
    Key? key,
    required this.trackingId,
    required this.valId,
    this.reason,
    this.errorMessage,
  }) : super(key: key);

  @override
  State<FailedOrderScreenWidget> createState() => _FailedOrderScreenWidgetState();
}

class _FailedOrderScreenWidgetState extends State<FailedOrderScreenWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(
          mobile: _body(),
          desktop: _body(),
          tablet: _body(),
        ),
      ),
    );
  }

  Widget _body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)),
                  (route) => false,
            );
          },
          child: Container(height: 60, child: AppBarHeader("Payment Failed")),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedboxSpaccing.height045(context),

                // Animated Error Icon
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 60,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedboxSpaccing.height03(context),

                // Failed Title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Payment Failed!',
                    style: AppTextStyles.textSize24(
                      context,
                      weight: FontWeight.w700,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedboxSpaccing.height015(context),

                // Failed Message
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Your payment could not be processed',
                    style: AppTextStyles.textSize16(
                      context,
                      weight: FontWeight.w400,
                      color: AppColors.subtitle(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedboxSpaccing.height03(context),

                // Tracking ID Card
                if (widget.trackingId.isNotEmpty)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.textFieldFill(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border(context)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Tracking ID',
                            style: AppTextStyles.textSize14(
                              context,
                              color: AppColors.subtitle(context),
                            ),
                          ),
                          SizedBox(height: 8),
                          SelectableText(
                            widget.trackingId,
                            style: AppTextStyles.textSize18(
                              context,
                              weight: FontWeight.w600,
                              color: AppColors.textPrimary(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),


                SizedboxSpaccing.height03(context),

                // What to do next section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: screenWidth * 0.9,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'What to do next?',
                              style: AppTextStyles.textSize16(
                                context,
                                weight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildBulletPoint(
                          'Check your payment method and try again',
                          context,
                        ),
                        _buildBulletPoint(
                          'Ensure you have sufficient balance',
                          context,
                        ),
                        _buildBulletPoint(
                          'Contact your bank if the issue persists',
                          context,
                        ),
                        _buildBulletPoint(
                          'Try using a different payment method',
                          context,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedboxSpaccing.height045(context),

                // Action Buttons
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Retry Payment Button
                      RoundButtonFlexible(
                          title:  'Retry Payment',
                          showRightIcon: false,
                          onPress: (){
                        Navigator.pop(context);
                      }),

                      SizedboxSpaccing.height015(context),

                      // Go to Home Button
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NavigationScreen(initialIndex: 0),
                            ),
                                (route) => false,
                          );
                        },
                        child: Container(
                          width: screenWidth * 0.9,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.border(context),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Go to Home',
                              style: AppTextStyles.textSize16(
                                context,
                                weight: FontWeight.w600,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedboxSpaccing.height02(context),

                      // Contact Support Button
                      GestureDetector(
                        onTap: () {
                          // Navigate to support or show contact options
                          _showContactSupport(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.headset_mic_outlined,
                                size: 20,
                                color: AppColors.button(context),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Contact Customer Support',
                                style: AppTextStyles.textSize14(
                                  context,
                                  weight: FontWeight.w500,
                                  color: AppColors.button(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedboxSpaccing.height02(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.textSize14(
                context,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.containerBackground(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Contact Support',
                style: AppTextStyles.textSize20(context, weight: FontWeight.w600),
              ),
              SizedBox(height: 20),
              _buildContactOption(
                icon: Icons.phone,
                title: 'Call Us',
                subtitle: '+880 1234-567890',
                onTap: () {
                  // Handle phone call
                },
              ),
              SizedBox(height: 12),
              _buildContactOption(
                icon: Icons.email,
                title: 'Email Us',
                subtitle: 'support@dinmajur.com',
                onTap: () {
                  // Handle email
                },
              ),
              SizedBox(height: 12),
              _buildContactOption(
                icon: Icons.chat_bubble_outline,
                title: 'Live Chat',
                subtitle: 'Chat with our support team',
                onTap: () {
                  // Handle live chat
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.textFieldFill(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.button(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.button(context)),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.textSize16(
                      context,
                      weight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.textSize14(
                      context,
                      color: AppColors.subtitle(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.subtitle(context)),
          ],
        ),
      ),
    );
  }
}