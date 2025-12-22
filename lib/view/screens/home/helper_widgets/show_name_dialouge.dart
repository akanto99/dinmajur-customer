import 'package:dinmajur_customer/configs/widgets/custometext_formfield.dart';
import 'package:dinmajur_customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/buttons/round_button.dart';
import 'package:dinmajur_customer/view_model/homeview_model/profileview_model/profileview_model.dart';
import 'package:provider/provider.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';

class NameEntryDialog extends StatefulWidget {
  const NameEntryDialog({Key? key}) : super(key: key);

  @override
  State<NameEntryDialog> createState() => _NameEntryDialogState();
}

class _NameEntryDialogState extends State<NameEntryDialog> {
  final TextEditingController _fullNameController = TextEditingController();
  final FocusNode _fullNameFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _fullNameFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final profileViewModel = Provider.of<ProfileViewViewModel>(context, listen: false);

      // Prepare the data for API
      final data = {
        "fullName": _fullNameController.text.trim(),
      };

      // Call the API to update profile (don't show success message)
      await profileViewModel.profileUpdatePatchApi(
        context,
        data,
        showSuccessMessage: false, // Suppress success message
      );

      // Refresh profile data to get updated info
      await profileViewModel.fetchProfileViewUserDataApi(forceRefresh: true);

      // ✅ Wait for any pending UI updates to complete before closing
      if (mounted) {
        // Use addPostFrameCallback to ensure all builds are complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);

        // Show error message without closing dialog
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
      onWillPop: () async => false, // Prevent back button
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

                // Using CustometextFormfield like in WelcomeLoginScreen
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

                SizedboxSpaccing.height025(context),

                // Using RoundButton like in WelcomeLoginScreen
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

// Helper function to show the dialog
Future<void> showNameEntryDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false, // User must enter name
    builder: (context) => NameEntryDialog(),
  );
}