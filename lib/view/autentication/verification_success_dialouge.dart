import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:flutter/material.dart';

class VerificationSuccessScreen extends StatefulWidget {
  const VerificationSuccessScreen({super.key});

  @override
  State<VerificationSuccessScreen> createState() => _VerificationSuccessScreenState();
}

class _VerificationSuccessScreenState extends State<VerificationSuccessScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _checkmarkAnimationController;
  late AnimationController _fadeInAnimationController;
  late AnimationController _buttonAnimationController;

  // Animations
  late Animation<double> _checkmarkScaleAnimation;
  late Animation<double> _checkmarkRotationAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<Offset> _slideUpAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _checkmarkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeInAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Setup animations
    _checkmarkScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkmarkAnimationController,
      curve: Curves.elasticOut,
    ));

    _checkmarkRotationAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _checkmarkAnimationController,
      curve: Curves.easeOutBack,
    ));

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeInAnimationController,
      curve: Curves.easeInOut,
    ));

    _slideUpAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeInAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start animations with delay
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _checkmarkAnimationController.forward();
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      _fadeInAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _checkmarkAnimationController.dispose();
    _fadeInAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.globalBlackWhite(context),
        body: ResPonsiveUi(
          mobile: body(),
          desktop: body(),
          tablet: body(),
        ),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [ Container(
        // padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
        height: 60,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border(context), width: 1.0)),
        ),
        child: Center(
          child:
          Text("Verification", style: AppTextStyles.poppinsH3(context, weight: FontWeight.w600)),

        ),
      ),

        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              AnimatedBuilder(
                animation: _checkmarkAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _checkmarkScaleAnimation.value,
                    child: Transform.rotate(
                      angle: _checkmarkRotationAnimation.value,
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.1),
                        ),
                        child: Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF0D5A5A), // Teal color from design
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedboxSpaccing.height04(context),
              SizedboxSpaccing.height02(context),

              // Success message card
              SlideTransition(
                position: _slideUpAnimation,
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Container(
                    width: screenWidth * 0.9,
                    padding: EdgeInsets.all(screenHeight * 0.02),
                    decoration: BoxDecoration(
                      color:AppColors.containerBackground(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        width: 1,
                        color: AppColors.border(context)
                      )
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Verification Successful!",
                          style: AppTextStyles.poppinsH3(context,weight: FontWeight.w600,color: AppColors.button(context))),

                        SizedboxSpaccing.height01(context),

                        Text(
                          "Your phone number has been\nsuccessfully verified.",
                          style: AppTextStyles.poppins14(context,
                            weight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedboxSpaccing.height025(context),

              SlideTransition(
                position: _slideUpAnimation,
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Container(
                    width: screenWidth*0.9,
                    child: Column(
                      children: [
                        // Continue to App button
                        AnimatedBuilder(
                          animation: _buttonScaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _buttonScaleAnimation.value,
                              child: GestureDetector(
                                onTapDown: (_) => _buttonAnimationController.forward(),
                                onTapUp: (_) => _buttonAnimationController.reverse(),
                                onTapCancel: () => _buttonAnimationController.reverse(),
                                child: RoundButton(
                                  title: "Continue to App",
                                  onPress: (){
                                    Navigator.pushNamed(context, RoutesName.navigationBar);
                                  },
                                  iconData: Icons.arrow_forward_ios_rounded,
                                  loading: false,
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: screenHeight * 0.025),

                        // Set up profile later button
                        GestureDetector(
                          onTap: (){
                            Navigator.pushNamed(context, RoutesName.welcomeLoginSignup);
                          },
                          child: Container(
                            child: Text(
                              "I'll set up my profile later",
                              style: AppTextStyles.poppins16(context,
                                weight: FontWeight.w500,
                              )
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ],
    );
  }
}