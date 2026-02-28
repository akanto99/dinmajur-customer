import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/language_changer/language_changer_widgets.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/configs/validations/authentication_validation/welcome_login_validation.dart';
import 'package:dinmajur_customer/configs/widgets/customemobile_textfield.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:dinmajur_customer/view_model/auth_view_model_new/customer_authlogin_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

class WelcomeLoginScreen extends StatefulWidget {
  const WelcomeLoginScreen({super.key});

  @override
  State<WelcomeLoginScreen> createState() => _WelcomeLoginSignupState();
}

class _WelcomeLoginSignupState extends State<WelcomeLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();

  late final Upgrader _upgrader;
  bool _upgradeChecked = false;

  @override
  void initState() {
    super.initState();
    _upgrader = Upgrader(countryCode: 'BD', languageCode: 'en');
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpgrade(context));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(child: ResPonsiveUi(mobile: _body(), desktop: _body(), tablet: _body())),
    );
  }

  Widget _body() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(  // ← no SingleChildScrollView
      children: [
        // ── Top: SVG Part ─────────────────────────────────────────────
        Expanded(
          child: ColoredBox(
            color: AppColors.border(context),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: screenHeight*0.4,
                    child: SvgPicture.asset(
                      "assets/images/login/welcome.svg",
                      width: screenWidth,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: LanguageSlideSwitcher(
                    backgroundColor: AppColors.textPrimary(context),
                    activeColor: Colors.white,
                    inactiveColor: AppColors.textPrimary(context),
                    borderRadius: BorderRadius.circular(25),
                    animationDuration: const Duration(milliseconds: 250),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Bottom: Welcome Part ──────────────────────────────────────
        Expanded(
          child: Container(
            color: AppColors.border(context),
            child: Container(
              width: screenWidth,
              decoration: BoxDecoration(
                color: AppColors.containerBackground(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedboxSpaccing.height04(context),
                    Text(
                      AppLocalizations.of(context)!.welcome,
                      style: AppTextStyles.textSize24(context, weight: FontWeight.w600),
                    ),
                    Text(
                      AppLocalizations.of(context)!.welcome_subtitle,
                      style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
                    ),
                    SizedboxSpaccing.height04(context),
                    CustomeMobileTextfield(
                      placeholder: AppLocalizations.of(context)!.phone_hint_new,
                      controller: _phoneController,
                      focusCurrent: _phoneFocus,
                      keyboardType: TextInputType.number,
                    ),
                    SizedboxSpaccing.height025(context),
                    Consumer<CustomerAuthLoginViewModel>(
                      builder: (context, vm, _) => SizedBox(
                        width: screenWidth * 0.75,
                        child: RoundButton(
                          title: AppLocalizations.of(context)!.login_with_otp,
                          iconData: Icons.arrow_forward_ios_rounded,
                          loading: vm.authApiSendOtploading,
                          onPress: () => _onLoginPressed(vm),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onLoginPressed(CustomerAuthLoginViewModel vm) {
    final String? error = WelcomeLoginValidation.getFirstLoginError(
      phone: _phoneController.text,
    );

    if (error != null) {
      Utils.flushBarErrorMessage(error, context);
      return;
    }

    final Map<String, String> data = {
      'phone': _phoneController.text.trim(),
      'role': 'CUSTOMER',
    };

    vm.authApiSendOtp(data, context, onSuccess: () async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pushNamed(
          context,
          RoutesName.authOtp,
          arguments: {
            'phone': _phoneController.text.trim(),
            'role': 'CUSTOMER',
          },
        );
      }
    });
  }

  void _checkForUpgrade(BuildContext context) async {
    if (_upgradeChecked || !mounted) return;
    _upgradeChecked = true;

    await _upgrader.initialize();
    if (!mounted) return;

    if (_upgrader.shouldDisplayUpgrade()) {
      _showCustomUpgradeDialog(context, _upgrader);
    }
  }

  void _showCustomUpgradeDialog(BuildContext context, Upgrader upgrader) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.showDialougeBackground(context),
      builder: (_) => Dialog(
        backgroundColor: AppColors.containerBackground(context),
        insetPadding: EdgeInsets.all(screenHeight * 0.02),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(screenHeight * 0.02),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Icon(FontAwesomeIcons.cloudArrowDown, color: AppColors.button(context), size: 50),
              const SizedBox(height: 10),
              Text('Update Available', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
              const SizedBox(height: 20),
              Text('A new version is available!', textAlign: TextAlign.center, style: AppTextStyles.textSize14(context)),
              const SizedBox(height: 5),
              Text(
                'Version ${upgrader.currentAppStoreVersion ?? 'Unknown'} is now available. '
                    'You are using version ${upgrader.currentInstalledVersion ?? 'Unknown'}.',
                textAlign: TextAlign.center,
                style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  Navigator.of(context).pop();
                  await upgrader.sendUserToAppStore();
                },
                child: Container(
                  width: screenWidth * 0.5,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.button(context),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      'Update Now',
                      style: AppTextStyles.textSize14(context, color: AppColors.whiteColor, weight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}