import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreenUpdated extends StatefulWidget {
  const OnboardingScreenUpdated({super.key});

  @override
  State<OnboardingScreenUpdated> createState() => _OnboardingScreenUpdatedState();
}

class _OnboardingScreenUpdatedState extends State<OnboardingScreenUpdated>
    with TickerProviderStateMixin {
  final controller = PageController(viewportFraction: 1.0);
  bool isLastPage = false;
  int currentIndex = 0;

  // Enhanced animation controllers
  late AnimationController _buttonAnimationController;
  late AnimationController _pageTransitionController;
  late AnimationController _svgAnimationController;

  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _pageOpacityAnimation;
  late Animation<double> _svgScaleAnimation;
  late Animation<Offset> _svgSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Button animation controller
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));

    // Page transition controller
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _pageOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeInOut,
    ));

    // SVG animation controller
    _svgAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _svgScaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _svgAnimationController,
      curve: Curves.easeOut,
    ));
    _svgSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _svgAnimationController,
      curve: Curves.easeOut,
    ));

    // Start initial animations
    _pageTransitionController.forward();
    _svgAnimationController.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    _buttonAnimationController.dispose();
    _pageTransitionController.dispose();
    _svgAnimationController.dispose();
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
      children: [
        SizedboxSpaccing.height015(context),
        // Skip button with smooth animation
        AnimatedBuilder(
          animation: _pageOpacityAnimation,
          builder: (context, child) => Opacity(
            opacity: _pageOpacityAnimation.value,
            child: Container(
              width: screenWidth * 0.9,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _skipOnboarding,
                    child: Text(
                      "স্কিপ",
                      style: AppTextStyles.poppins24(context,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedboxSpaccing.width03(context),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 24),
                ],
              ),
            ),
          ),
        ),

        // Enhanced PageView with smoother transitions
        Expanded(
          child: PageView.builder(
            controller: controller,
            physics: const ClampingScrollPhysics(),
            onPageChanged: (index) {
              _onPageChanged(index);
            },
            itemCount: 3,
            itemBuilder: (context, index) {
              return buildPage(
                svgAsset: _getSvgAsset(index),
                title: _getTitle(index),
                subtitle: _getSubtitle(index),
                isActive: index == currentIndex,
                pageIndex: index,
              );
            },
          ),
        ),


      Container(
        height: screenHeight*0.4,
        child: Column(
          children: [
            // Text animations with proper data flow
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 400),
              child: Container(
                width: screenWidth * 0.9,
                child: Text(
                  _getTitle(currentIndex),
                  style:AppTextStyles.poppinsH2(context, weight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            SizedboxSpaccing.height015(context),

            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 400),
              child: Container(
                width: screenWidth * 0.9,
                child: Text(
                  _getSubtitle(currentIndex),
                  style: AppTextStyles.poppins18(context, weight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            SizedboxSpaccing.height04(context),
            SizedboxSpaccing.height04(context),

            // Enhanced next arrow button
            AnimatedBuilder(
              animation: Listenable.merge([_buttonScaleAnimation, _pageOpacityAnimation]),
              builder: (context, child) {
                return Opacity(
                  opacity: _pageOpacityAnimation.value,
                  child: Transform.scale(
                    scale: _buttonScaleAnimation.value,
                    child: nextArrow(
                      assetImage: _getArrowAsset(currentIndex),
                      onTapFunction: currentIndex == 2 ? _goToHome : _nextPage,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      ],
    );
  }

  // Enhanced page change handler
  void _onPageChanged(int index) {
    if (mounted) {
      setState(() {
        currentIndex = index;
        isLastPage = index == 2;
      });

      // Restart SVG animations for new page
      if (!_svgAnimationController.isAnimating) {
        _svgAnimationController.reset();
        _svgAnimationController.forward();
      }
    }
  }

  String _getSvgAsset(int index) {
    switch (index) {
      case 0:
        return "assets/images/onboard/trainedIMG.svg";
      case 1:
        return "assets/images/onboard/elaka.svg";
      case 2:
        return "assets/images/onboard/earning.svg";
      default:
        return "assets/images/onboard/onboard1.svg";
    }
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'আমি হব প্রশিক্ষিত দিনমজুর';
      case 1:
        return 'আমার দক্ষতা হবে আমার আয়';
      case 2:
        return 'নিজ এলাকার কাজের সুযোগ';
      default:
        return 'দক্ষ কর্মী, ঘরে বসেই সেবা!';
    }
  }

  String _getSubtitle(int index) {
    switch (index) {
      case 0:
        return "আমার দক্ষতা, আমার পরিচয়";
      case 1:
        return "আয়ের নতুন সুযোগ";
      case 2:
        return "আমার এলাকার কাজ, আমার হাতে";
      default:
        return "ব্যস্ত জীবন, সহজ সমাধান";
    }
  }

  String _getArrowAsset(int index) {
    switch (index) {
      case 0:
        return "assets/images/onboard/icons/arrow1.svg";
      case 1:
        return "assets/images/onboard/icons/arrow2.svg";
      case 2:
        return "assets/images/onboard/icons/gobutton.svg";
      default:
        return "assets/images/onboard/icons/arrow1.svg";
    }
  }

  Widget nextArrow({
    required String assetImage,
    required VoidCallback onTapFunction,
  }) {
    return GestureDetector(
      onTapDown: (_) {
        _buttonAnimationController.forward();
      },
      onTapUp: (_) {
        _buttonAnimationController.reverse();
      },
      onTapCancel: () {
        _buttonAnimationController.reverse();
      },
      onTap: () {
        _buttonAnimationController.forward().then((_) {
          _buttonAnimationController.reverse();
        });
        onTapFunction();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 85,
        width: 85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.15)
                  : Colors.white,
              blurRadius: 15,
              offset: const Offset(0, 6),
              spreadRadius: 2,
            ),
          ],
        ),
        child: SizedBox(
          height: 35,
          width: 35,
          child: SvgPicture.asset(
            assetImage,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  /// Next page function
  void _nextPage() {
    if (currentIndex >= 2) return;

    controller.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  /// Skip onboarding
  void _skipOnboarding() async {
    _pageTransitionController.reverse();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("showHome", true);

    if (mounted) {
      Navigator.pushNamed(context, RoutesName.welcomeLoginSignup);
    }
  }

  /// Navigate to login
  void _goToHome() async {
    _pageTransitionController.reverse();

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('showHome', true);

    if (mounted) {
      Navigator.pushNamed(context, RoutesName.welcomeLoginSignup);
    }
  }

  Widget buildPage({
    required String svgAsset,
    required String title,
    required String subtitle,
    required bool isActive,
    required int pageIndex,
  }) {
    final screenWidth = MediaQuery.of(context).size.width*1;
    final screenHeight = MediaQuery.of(context).size.height*1;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double opacity = 1.0;
        double scale = 1.0;

        // Safe check for controller position
        if (controller.hasClients && controller.position.haveDimensions) {
          double value = (controller.page ?? currentIndex.toDouble()) - pageIndex;
          opacity = (1 - value.abs().clamp(0.0, 1.0)) * 0.5 + 0.5;
          scale = 1.0 - (value.abs() * 0.05).clamp(0.0, 0.05);
        }

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              height: screenHeight*0.5,
              color: AppColors.containerBackground(context),
              width: double.infinity,
              child: AnimatedOpacity(
                opacity: isActive ? 1.0 : 0.8,
                duration: const Duration(milliseconds: 400),
                child: AnimatedScale(
                  scale: isActive ? 1.0 : 0.95,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  child: SvgPicture.asset(
                    svgAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}