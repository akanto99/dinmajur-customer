import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Data
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

// Main StatefulWidget — only holds state + animation controllers
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

// Body — StatelessWidget, rebuilt only when parent setState fires
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

// Single onboarding page — isolated repaint layer
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

// Arrow button — isolated widget, not recreated in AnimatedBuilder
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