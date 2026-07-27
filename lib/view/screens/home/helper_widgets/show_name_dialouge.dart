import 'package:dinmajur_customer/configs/widgets/custometext_formfield.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/model/referral/referral_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:provider/provider.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';

class NameEntryDialog extends StatefulWidget {
  // Whether this customer already made their one-shot referral-code decision
  // (e.g. a code auto-applied from a deep link before this dialog even
  // showed). When true, the referral field is hidden entirely — there is no
  // other place in the app to enter a code afterwards.
  final bool referralChoiceMade;

  const NameEntryDialog({Key? key, required this.referralChoiceMade}) : super(key: key);

  @override
  State<NameEntryDialog> createState() => _NameEntryDialogState();
}

class _NameEntryDialogState extends State<NameEntryDialog> {
  final TextEditingController _fullNameController = TextEditingController();
  final FocusNode _fullNameFocus = FocusNode();
  final TextEditingController _referralCodeController = TextEditingController();
  final FocusNode _referralCodeFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _fullNameFocus.dispose();
    _referralCodeController.dispose();
    _referralCodeFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);
      final referralCode = _referralCodeController.text.trim();
      final data = {
        "fullName": _fullNameController.text.trim(),
        // Only ever sent once — this dialog is the single entry point for a
        // referral code. Omitted entirely once the choice has already been
        // made, so a resubmission can never smuggle a code in later.
        if (!widget.referralChoiceMade && referralCode.isNotEmpty) "referralCode": referralCode,
      };
      final response = await profileViewModel.profileUpdatePatchApi(
        context,
        data,
        showSuccessMessage: false,
      );
      await profileViewModel.fetchProfileViewUserDataApi(forceRefresh: true);
      final responseMap = response is Map ? response : null;
      final couponJson = responseMap?['data']?['referralCoupon'];
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          Navigator.of(context).pop();
          if (couponJson != null) {
            await _showCouponEarnedDialog(context, AppliedReferralCoupon.fromJson(couponJson));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          Utils.flushBarErrorMessage("Failed to update name. Please try again.", context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.containerBackground(context),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Nick Name",
                  style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                ),
                SizedboxSpaccing.height02(context),
                CustometextFormfield(
                  placeholder: AppLocalizations.of(context)!.fullName_hint,
                  controller: _fullNameController,
                  focusCurrent: _fullNameFocus,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Trigger validation on change
                    _formKey.currentState?.validate();
                  },
                ),

                // Referral code can only ever be entered right here. Hidden
                // once the choice has already been made (e.g. auto-applied
                // from a referral deep link before this dialog showed) —
                // there's nothing left to decide at that point.
                if (!widget.referralChoiceMade) ...[
                  SizedboxSpaccing.height02(context),
                  CustometextFormfield(
                    placeholder: 'Referral code (optional)',
                    controller: _referralCodeController,
                    focusCurrent: _referralCodeFocus,
                    keyboardType: TextInputType.text,
                  ),
                ],

                SizedboxSpaccing.height025(context),
                Consumer<ProfileViewViewModel>(
                  builder: (context, profileViewModel, _) {
                    return Container(
                      width: screenWidth * 0.75,
                      child: RoundButton(
                        title: 'Submit',
                        iconData: Icons.arrow_forward_ios_rounded,
                        loading: profileViewModel.profileHeaderUpdateLoading,
                        onPress: _handleSubmit,
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showNameEntryDialog(BuildContext context, {required bool referralChoiceMade}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.showDialougeBackground(context),
    builder: (context) => NameEntryDialog(referralChoiceMade: referralChoiceMade),
  );
}

/// Shown once, right after a referral code entered in [NameEntryDialog] is
/// applied successfully — the referee's coupon is issued immediately.
Future<void> _showCouponEarnedDialog(BuildContext context, AppliedReferralCoupon coupon) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: AppColors.containerBackground(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration_rounded, size: 44, color: AppColors.button(context)),
            SizedboxSpaccing.height02(context),
            Text('You got a coupon!', style: AppTextStyles.textSize18(context, weight: FontWeight.w700)),
            SizedboxSpaccing.height01(context),
            Text(
              'Referral code applied — here is your reward.',
              textAlign: TextAlign.center,
              style: AppTextStyles.textSize13(context, color: AppColors.subtitle(context)),
            ),
            SizedboxSpaccing.height02(context),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.button(context).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.button(context).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(coupon.code, style: AppTextStyles.textSize18(context, weight: FontWeight.w700).copyWith(letterSpacing: 0.5)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: coupon.code));
                          Utils.flushBarSuccessMessage('Coupon code copied', context);
                        },
                        child: Icon(Icons.copy_rounded, size: 18, color: AppColors.button(context)),
                      ),
                    ],
                  ),
                  SizedboxSpaccing.height005(context),
                  Text(coupon.discountLabel, style: AppTextStyles.textSize14(context, weight: FontWeight.w600, color: AppColors.button(context))),
                ],
              ),
            ),
            SizedboxSpaccing.height02(context),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button(context),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Great!', style: AppTextStyles.textSize14(context, weight: FontWeight.w600, color: AppColors.whiteColor)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}