import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/view_model/homeview_model/drawer_view_model/support_view_model/support_view_model.dart';
import 'package:dinmajur_customer/view_model/userview_model/userview_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class Support extends StatefulWidget {
  const Support({super.key});

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  late TextEditingController supportTextController = TextEditingController();

  @override
  void dispose() {
    supportTextController.dispose();
    super.dispose();
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
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: 60,
            color: AppColors.containerBackground(context),
            child: Center(child: AppBarHeader("Support")),
          ),
        ),
        SizedboxSpaccing.height025(context),
        Container(
          width: screenWidth * 0.9,
          padding: EdgeInsets.all(screenHeight * 0.02),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(width: 1, color: AppColors.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Please leave us a message and we will get back to you shortly', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
              SizedboxSpaccing.height02(context),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 1, color: AppColors.border(context)),
                ),
                child: TextFormField(
                  controller: supportTextController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  style: AppTextStyles.textSize16(context, weight: FontWeight.w400),
                  decoration: InputDecoration(
                    hintText: "Input Text Here",
                    hintStyle: AppTextStyles.textSize16(context, color: AppColors.subtitle(context), weight: FontWeight.w400),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  ),
                ),
              ),
              SizedboxSpaccing.height02(context),
              Consumer<PostSupportViewModel>(
                builder: (context, supportModel, child) {
                  return GestureDetector(
                    onTap: () async {
                      // Check if message is empty
                      if (supportTextController.text.isEmpty) {
                        Utils.flushBarErrorMessage("Please drop your message", context);
                        return;
                      }

                      // Get user data
                      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
                      final userId = userViewModel.userId;

                      if (userId == null || userId.isEmpty) {
                        Utils.flushBarErrorMessage("User not found. Please login again.", context);
                        return;
                      }

                      // Prepare data for API call
                      final supportData = {
                        'userId': userId,
                        'message': supportTextController.text,
                        // Add other required fields based on your API requirements
                      };

                      print("userId : $userId");
                      print(supportTextController);

                      // Call the API
                      await supportModel.supportPostAPI(context, supportData);

                      // Clear the text field after successful submission
                      supportTextController.clear();
                    },
                    child: Container(
                      width: screenWidth * 0.425,
                      height: 50,
                      decoration: BoxDecoration(color: Color(0xff00424D), borderRadius: BorderRadius.circular(12)),
                      child: Center(
                        child: supportModel.createSupportLoading
                            ? Text(
                                'Waiting...',
                                style: AppTextStyles.textSize16(context, color: AppColors.whiteColor, weight: FontWeight.w700),
                              )
                            : Text(
                                "Submit",
                                style: AppTextStyles.textSize16(context, color: AppColors.whiteColor, weight: FontWeight.w600),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizedboxSpaccing.height02(context),
        _buildSupportsSection(screenWidth, screenHeight),
      ],
    );
  }

  Widget _buildSupportsSection(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Support', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
          SizedboxSpaccing.height01(context),
          Divider(height: 1, color: AppColors.border(context)),
          SizedboxSpaccing.height02(context),
          Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.all(screenHeight * 0.02),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 1, color: AppColors.border(context)),
            ),
            child: Column(
              children: [
                _buildContactItem(icon: FontAwesomeIcons.phone, value: 'Call Us: +8801929600600'),
                SizedboxSpaccing.height015(context),
                _buildContactItem(icon: FontAwesomeIcons.solidEnvelope, value: 'Email: dinmajuri@gmail.com'),
                SizedboxSpaccing.height015(context),
                _buildContactItem(icon:FontAwesomeIcons.solidCommentDots,value: 'Live Chat'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({required IconData icon, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textPrimary(context)),
        SizedboxSpaccing.width03(context),
        SizedboxSpaccing.width01(context),
        Text(value, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
      ],
    );
  }
}
