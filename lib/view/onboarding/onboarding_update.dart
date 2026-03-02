// import 'package:dinmajur_customer/configs/res/color.dart';
// import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
// import 'package:dinmajur_customer/configs/res/text_styles.dart';
// import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
// import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class OnboardingScreenUpdated extends StatefulWidget {
//   const OnboardingScreenUpdated({super.key});
//
//   @override
//   State<OnboardingScreenUpdated> createState() => _OnboardingScreenUpdatedState();
// }
//
// class _OnboardingScreenUpdatedState extends State<OnboardingScreenUpdated>
//     with TickerProviderStateMixin {
//   final controller = PageController(viewportFraction: 1.0);
//   bool isLastPage = false;
//   int currentIndex = 0;
//
//   // Enhanced animation controllers
//   late AnimationController _buttonAnimationController;
//   late AnimationController _pageTransitionController;
//   late AnimationController _svgAnimationController;
//
//   late Animation<double> _buttonScaleAnimation;
//   late Animation<double> _pageOpacityAnimation;
//   late Animation<double> _svgScaleAnimation;
//   late Animation<Offset> _svgSlideAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Button animation controller
//     _buttonAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 150),
//       vsync: this,
//     );
//     _buttonScaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.95,
//     ).animate(CurvedAnimation(
//       parent: _buttonAnimationController,
//       curve: Curves.easeInOut,
//     ));
//
//     // Page transition controller
//     _pageTransitionController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//     _pageOpacityAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _pageTransitionController,
//       curve: Curves.easeInOut,
//     ));
//
//     // SVG animation controller
//     _svgAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//     _svgScaleAnimation = Tween<double>(
//       begin: 0.9,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _svgAnimationController,
//       curve: Curves.easeOut,
//     ));
//     _svgSlideAnimation = Tween<Offset>(
//       begin: const Offset(0.0, 0.1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _svgAnimationController,
//       curve: Curves.easeOut,
//     ));
//
//     // Start initial animations
//     _pageTransitionController.forward();
//     _svgAnimationController.forward();
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     _buttonAnimationController.dispose();
//     _pageTransitionController.dispose();
//     _svgAnimationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.globalBlackWhite(context),
//       body: SafeArea(
//         child: ResPonsiveUi(
//           mobile: body(),
//           desktop: body(),
//           tablet: body(),
//         ),
//       ),
//     );
//   }
//
//   Widget body() {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Column(
//       children: [
//         SizedboxSpaccing.height015(context),
//         // Skip button with smooth animation
//         AnimatedBuilder(
//           animation: _pageOpacityAnimation,
//           builder: (context, child) => Opacity(
//             opacity: _pageOpacityAnimation.value,
//             child: Container(
//               width: screenWidth * 0.9,
//               alignment: Alignment.centerRight,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   GestureDetector(
//                     onTap: _skipOnboarding,
//                     child: Text(
//                       "স্কিপ",
//                       style: AppTextStyles.textSize22(context,
//                         weight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   SizedboxSpaccing.width03(context),
//                   const Icon(Icons.arrow_forward_ios_rounded, size: 24),
//                 ],
//               ),
//             ),
//           ),
//         ),
//
//         // Enhanced PageView with smoother transitions
//         Expanded(
//           child: PageView.builder(
//             controller: controller,
//             physics: const ClampingScrollPhysics(),
//             onPageChanged: (index) {
//               _onPageChanged(index);
//             },
//             itemCount: 3,
//             itemBuilder: (context, index) {
//               return buildPage(
//                 svgAsset: _getSvgAsset(index),
//                 title: _getTitle(index),
//                 subtitle: _getSubtitle(index),
//                 isActive: index == currentIndex,
//                 pageIndex: index,
//               );
//             },
//           ),
//         ),
//
//
//       Container(
//         height: screenHeight*0.4,
//         child: Column(
//           children: [
//             // Text animations with proper data flow
//             AnimatedOpacity(
//               opacity: 1.0,
//               duration: const Duration(milliseconds: 400),
//               child: Container(
//                 width: screenWidth * 0.9,
//                 child: Text(
//                   _getTitle(currentIndex),
//                   style:AppTextStyles.textSize26(context, weight: FontWeight.w600),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//
//             SizedboxSpaccing.height015(context),
//
//             AnimatedOpacity(
//               opacity: 1.0,
//               duration: const Duration(milliseconds: 400),
//               child: Container(
//                 width: screenWidth * 0.9,
//                 child: Text(
//                   _getSubtitle(currentIndex),
//                   style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//
//             SizedboxSpaccing.height04(context),
//             SizedboxSpaccing.height04(context),
//
//             // Enhanced next arrow button
//             AnimatedBuilder(
//               animation: Listenable.merge([_buttonScaleAnimation, _pageOpacityAnimation]),
//               builder: (context, child) {
//                 return Opacity(
//                   opacity: _pageOpacityAnimation.value,
//                   child: Transform.scale(
//                     scale: _buttonScaleAnimation.value,
//                     child: nextArrow(
//                       assetImage: _getArrowAsset(currentIndex),
//                       onTapFunction: currentIndex == 2 ? _goToHome : _nextPage,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       ],
//     );
//   }
//
//   // Enhanced page change handler
//   void _onPageChanged(int index) {
//     if (mounted) {
//       setState(() {
//         currentIndex = index;
//         isLastPage = index == 2;
//       });
//
//       // Restart SVG animations for new page
//       if (!_svgAnimationController.isAnimating) {
//         _svgAnimationController.reset();
//         _svgAnimationController.forward();
//       }
//     }
//   }
//
//   String _getSvgAsset(int index) {
//     switch (index) {
//       case 0:
//         return "assets/images/onboard/house_keeper.svg";
//       case 1:
//         return "assets/images/onboard/beauty_salon.svg";
//       case 2:
//         return "assets/images/onboard/bazar.svg";
//       default:
//         return "assets/images/onboard/house_keeper.svg";
//     }
//   }
//
//   String _getTitle(int index) {
//     switch (index) {
//       case 0:
//         return 'প্রিমিয়াম হাউসকিপার হোম-সার্ভিস';
//         // return 'আমি হব প্রশিক্ষিত দিনমজুর';
//       case 1:
//         return 'প্রিমিয়াম হোম বিউটি & সেলুন';
//         // return 'আমার দক্ষতা হবে আমার আয়';
//       case 2:
//         return 'তাৎক্ষণিক বাজার সার্ভিস';
//         // return 'নিজ এলাকার কাজের সুযোগ';
//       default:
//         return 'দক্ষ কর্মী, ঘরে বসেই সেবা!';
//         // return 'দক্ষ কর্মী, ঘরে বসেই সেবা!';
//     }
//   }
//
//   String _getSubtitle(int index) {
//     switch (index) {
//       case 0:
//         return "আপনার ঘর, আমাদের দায়িত্ব";
//         // return "আমার দক্ষতা, আমার পরিচয়";
//       case 1:
//         return "আপনার সৌন্দর্য, আমাদের যত্ন";
//         // return "আয়ের নতুন সুযোগ";
//       case 2:
//         return "প্রয়োজনীয় সবকিছু, এক ক্লিক";
//         // return "আমার এলাকার কাজ, আমার হাতে";
//       default:
//         return "ব্যস্ত জীবন, সহজ সমাধান";
//         // return "ব্যস্ত জীবন, সহজ সমাধান";
//     }
//   }
//
//   String _getArrowAsset(int index) {
//     switch (index) {
//       case 0:
//         return "assets/images/onboard/icons/arrow1.svg";
//       case 1:
//         return "assets/images/onboard/icons/arrow2.svg";
//       case 2:
//         return "assets/images/onboard/icons/gobutton.svg";
//       default:
//         return "assets/images/onboard/icons/arrow1.svg";
//     }
//   }
//
//   Widget nextArrow({
//     required String assetImage,
//     required VoidCallback onTapFunction,
//   }) {
//     return GestureDetector(
//       onTapDown: (_) {
//         _buttonAnimationController.forward();
//       },
//       onTapUp: (_) {
//         _buttonAnimationController.reverse();
//       },
//       onTapCancel: () {
//         _buttonAnimationController.reverse();
//       },
//       onTap: () {
//         _buttonAnimationController.forward().then((_) {
//           _buttonAnimationController.reverse();
//         });
//         onTapFunction();
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         height: 85,
//         width: 85,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(50),
//           boxShadow: [
//             BoxShadow(
//               color: Theme.of(context).brightness == Brightness.dark
//                   ? Colors.black.withOpacity(0.15)
//                   : Colors.white,
//               blurRadius: 15,
//               offset: const Offset(0, 6),
//               spreadRadius: 2,
//             ),
//           ],
//         ),
//         child: SizedBox(
//           height: 35,
//           width: 35,
//           child: SvgPicture.asset(
//             assetImage,
//             fit: BoxFit.contain,
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// Next page function
//   void _nextPage() {
//     if (currentIndex >= 2) return;
//
//     controller.nextPage(
//       duration: const Duration(milliseconds: 400),
//       curve: Curves.easeInOut,
//     );
//   }
//
//   /// Skip onboarding
//   void _skipOnboarding() async {
//     _pageTransitionController.reverse();
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setBool("showHome", true);
//
//     if (mounted) {
//       Navigator.pushNamed(context, RoutesName.authLoginWelcome);
//     }
//   }
//
//   /// Navigate to auth_login
//   void _goToHome() async {
//     _pageTransitionController.reverse();
//
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setBool('showHome', true);
//
//     if (mounted) {
//       Navigator.pushNamed(context, RoutesName.authLoginWelcome);
//     }
//   }
//
//   Widget buildPage({
//     required String svgAsset,
//     required String title,
//     required String subtitle,
//     required bool isActive,
//     required int pageIndex,
//   }) {
//     final screenWidth = MediaQuery.of(context).size.width*1;
//     final screenHeight = MediaQuery.of(context).size.height*1;
//
//     return AnimatedBuilder(
//       animation: controller,
//       builder: (context, child) {
//         double opacity = 1.0;
//         double scale = 1.0;
//
//         // Safe check for controller position
//         if (controller.hasClients && controller.position.haveDimensions) {
//           double value = (controller.page ?? currentIndex.toDouble()) - pageIndex;
//           opacity = (1 - value.abs().clamp(0.0, 1.0)) * 0.5 + 0.5;
//           scale = 1.0 - (value.abs() * 0.05).clamp(0.0, 0.05);
//         }
//
//         return Transform.scale(
//           scale: scale,
//           child: Opacity(
//             opacity: opacity,
//             child: Container(
//               height: screenHeight*0.5,
//               color: AppColors.containerBackground(context),
//               width: double.infinity,
//               child: AnimatedOpacity(
//                 opacity: isActive ? 1.0 : 0.8,
//                 duration: const Duration(milliseconds: 400),
//                 child: AnimatedScale(
//                   scale: isActive ? 1.0 : 0.95,
//                   duration: const Duration(milliseconds: 400),
//                   curve: Curves.easeOut,
//                   child: SvgPicture.asset(
//                     svgAsset,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────
class _OnboardingData {
  static const List<String> svgAssets = [
    "assets/images/onboard/house_keeper.svg",
    "assets/images/onboard/beauty_salon.svg",
    "assets/images/onboard/bazar.svg",
  ];

  static const List<String> titles = [
    'প্রিমিয়াম হাউসকিপার হোম-সার্ভিস',
    'প্রিমিয়াম হোম বিউটি & সেলুন',
    'তাৎক্ষণিক বাজার সার্ভিস',
  ];

  static const List<String> subtitles = [
    "আপনার ঘর, আমাদের দায়িত্ব",
    "আপনার সৌন্দর্য, আমাদের যত্ন",
    "প্রয়োজনীয় সবকিছু, এক ক্লিক",
  ];

  static const List<String> arrowAssets = [
    "assets/images/onboard/icons/arrow1.svg",
    "assets/images/onboard/icons/arrow2.svg",
    "assets/images/onboard/icons/gobutton.svg",
  ];
}

// ─────────────────────────────────────────────────────────────
// Main StatefulWidget — only holds state + animation controllers
// ─────────────────────────────────────────────────────────────
class OnboardingScreenUpdated extends StatefulWidget {
  const OnboardingScreenUpdated({super.key});

  @override
  State<OnboardingScreenUpdated> createState() =>
      _OnboardingScreenUpdatedState();
}

class _OnboardingScreenUpdatedState extends State<OnboardingScreenUpdated>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  late final AnimationController _buttonAnimController;
  late final AnimationController _pageTransitionController;

  late final Animation<double> _buttonScaleAnim;
  late final Animation<double> _pageOpacityAnim;

  @override
  void initState() {
    super.initState();

    _buttonAnimController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonAnimController, curve: Curves.easeInOut),
    );

    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _pageOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _pageTransitionController, curve: Curves.easeInOut),
    );

    _pageTransitionController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonAnimController.dispose();
    _pageTransitionController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _nextPage() {
    if (_currentIndex >= 2) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _skipOrFinish() async {
    _pageTransitionController.reverse();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showHome', true);
    if (mounted) {
      Navigator.pushNamed(context, RoutesName.authLoginWelcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Build body ONCE — not 3 times
    final body = _OnboardingBody(
      pageController: _pageController,
      currentIndex: _currentIndex,
      buttonScaleAnim: _buttonScaleAnim,
      pageOpacityAnim: _pageOpacityAnim,
      onPageChanged: _onPageChanged,
      onSkip: _skipOrFinish,
      onNext: _nextPage,
      onGoHome: _skipOrFinish,
      onButtonTapDown: _buttonAnimController.forward,
      onButtonTapUp: _buttonAnimController.reverse,
    );

    return Scaffold(
      backgroundColor: AppColors.globalBlackWhite(context),
      body: SafeArea(
        child: ResPonsiveUi(
          mobile: body,
          desktop: body,
          tablet: body,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Body — StatelessWidget, rebuilt only when parent setState fires
// ─────────────────────────────────────────────────────────────
class _OnboardingBody extends StatelessWidget {
  final PageController pageController;
  final int currentIndex;
  final Animation<double> buttonScaleAnim;
  final Animation<double> pageOpacityAnim;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onGoHome;
  final VoidCallback onButtonTapDown;
  final VoidCallback onButtonTapUp;

  const _OnboardingBody({
    required this.pageController,
    required this.currentIndex,
    required this.buttonScaleAnim,
    required this.pageOpacityAnim,
    required this.onPageChanged,
    required this.onSkip,
    required this.onNext,
    required this.onGoHome,
    required this.onButtonTapDown,
    required this.onButtonTapUp,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ sizeOf — won't rebuild on keyboard/inset changes
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Column(
      children: [
        SizedboxSpaccing.height015(context),

        // ── Skip Button ───────────────────────────────────────────
        // ✅ child: passed so the Row is NOT rebuilt every animation tick
        AnimatedBuilder(
          animation: pageOpacityAnim,
          child: SizedBox(
            width: screenWidth * 0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onSkip,
                  child: Text(
                    "স্কিপ",
                    style: AppTextStyles.textSize22(context,
                        weight: FontWeight.w600),
                  ),
                ),
                SizedboxSpaccing.width03(context),
                const Icon(Icons.arrow_forward_ios_rounded, size: 24),
              ],
            ),
          ),
          builder: (context, child) =>
              Opacity(opacity: pageOpacityAnim.value, child: child),
        ),

        // ── SVG PageView ──────────────────────────────────────────
        Expanded(
          child: Container(
            height: 412,
            child: PageView.builder(
              controller: pageController,
              physics: const ClampingScrollPhysics(),
              onPageChanged: onPageChanged,
              itemCount: 3,
              itemBuilder: (context, index) => _OnboardingPage(
                svgAsset: _OnboardingData.svgAssets[index],
                isActive: index == currentIndex,
              ),
            ),
          ),
        ),

        // ── Bottom Text + Button ──────────────────────────────────
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedboxSpaccing.height015(context),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  key: ValueKey('title_$currentIndex'),
                  width: screenWidth * 0.9,
                  child: Text(
                    _OnboardingData.titles[currentIndex],
                    style: AppTextStyles.textSize26(context,
                        weight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              SizedboxSpaccing.height015(context),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  key: ValueKey('sub_$currentIndex'),
                  width: screenWidth * 0.9,
                  child: Text(
                    _OnboardingData.subtitles[currentIndex],
                    style: AppTextStyles.textSize18(context,
                        weight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

             SizedBox(height: 70,),
              // SizedboxSpaccing.height04(context),

              // ✅ child: passed — button widget not rebuilt every anim tick
              AnimatedBuilder(
                animation:
                Listenable.merge([buttonScaleAnim, pageOpacityAnim]),
                child: _NextArrowButton(
                  assetImage: _OnboardingData.arrowAssets[currentIndex],
                  onTap: currentIndex == 2 ? onGoHome : onNext,
                  onTapDown: onButtonTapDown,
                  onTapUp: onButtonTapUp,
                ),
                builder: (context, child) => Opacity(
                  opacity: pageOpacityAnim.value,
                  child: Transform.scale(
                    scale: buttonScaleAnim.value,
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Single onboarding page — isolated repaint layer
// ─────────────────────────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final String svgAsset;
  final bool isActive;

  const _OnboardingPage({
    required this.svgAsset,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ RepaintBoundary — GPU caches this layer, no re-rasterize on parent rebuild
    return RepaintBoundary(
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.8,
        duration: const Duration(milliseconds: 300),
        child: AnimatedScale(
          scale: isActive ? 1.0 : 0.95,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: SvgPicture.asset(
            svgAsset,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Arrow button — isolated widget, not recreated in AnimatedBuilder
// ─────────────────────────────────────────────────────────────
class _NextArrowButton extends StatelessWidget {
  final String assetImage;
  final VoidCallback onTap;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;

  const _NextArrowButton({
    required this.assetImage,
    required this.onTap,
    required this.onTapDown,
    required this.onTapUp,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapUp,
      onTap: onTap,
      child: RepaintBoundary( // ✅ isolates button repaint
        child: Container(
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
          child: SvgPicture.asset(
            assetImage,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}