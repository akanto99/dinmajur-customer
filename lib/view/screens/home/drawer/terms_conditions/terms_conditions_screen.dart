import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.02 ),

      child: Column(
        children: [
          // Main Container with Border
          Container(
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Header Section
                _buildHeaderSection(),

                Divider(height: 1, color: AppColors.border(context),),

                // Introduction and Terms Content Container
                Container(
                  padding: EdgeInsets.all(screenHeight * 0.02 ),
                  decoration: BoxDecoration(
                    color: AppColors.containerBackground(context),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                      border: Border.all(
                          width: 1,
                          color: AppColors.border(context)
                      )
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Introduction
                      _buildIntroText(),
                      SizedboxSpaccing.height025(context),

                      // All Terms Sections in One Container
                      Container(
                        padding: EdgeInsets.all(screenHeight * 0.015,),
                        decoration: BoxDecoration(
                          color: AppColors.containerBackground(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border(context)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTermSection(
                              '1. Service Overview',
                              [
                                'Dinmajur connects Customers with Retailers (shops within 1 km) and Service Providers (delivery agents).',
                                'Dinmajur itself does not sell products; it acts as a digital platform only.',
                              ],
                            ),

                            _buildTermSection(
                              '2. Account Registration & Verification',
                              [
                                'You must register with a valid mobile number and OTP.',
                                'You may edit your profile to add name and address.',
                                'You are responsible for providing accurate and up-to-date details.',
                              ],
                            ),

                            _buildTermSection(
                              '3. User Responsibilities',
                              [
                                'Keep your account information secure.',
                                'Do not use the app for fraudulent, illegal, or harmful activities.',
                                'You are responsible for ensuring correct delivery address and availability to receive orders.',
                              ],
                            ),

                            _buildTermSection(
                              '4. Orders & Fulfillment',
                              [
                                'Customers can place orders from nearby retailers (within 1 km).',
                                'Orders are delivered by assigned Service Providers.',
                                'You must verify delivery with OTP when receiving products.',
                              ],
                            ),

                            _buildTermSection(
                              '5. Payments',
                              [
                                'Payments can be made in cash on delivery or, in future, via secure gateways (bKash, Nagad, Rocket, Bank Transfer).',
                                'Dinmajur does not store your payment details.',
                                'Refunds, disputes, and payment policies will follow Dinmajur\'s Payment Policy (if enabled later).',
                              ],
                            ),

                            _buildTermSection(
                              '6. Intellectual Property',
                              [
                                'All app content, design, and technology belong to Dinmajur.',
                                'Customers retain ownership of personal details but grant Dinmajur permission to process data for app functionality.',
                              ],
                            ),

                            _buildTermSection(
                              '7. Limitation of Liability',
                              [
                                'Dinmajur is a platform and is not directly responsible for product quality, pricing, or delays by retailers/service providers.',
                                'You agree to use the Application at your own risk.',
                              ],
                            ),

                            _buildTermSection(
                              '8. Suspension & Termination',
                              [
                                'We may suspend or terminate your account if you:',
                              ],
                              subPoints: [
                                'Violate these Terms',
                                'Provide false or misleading information',
                                'Engage in fraudulent or harmful activity',
                              ],
                            ),

                            _buildTermSection(
                              '9. Governing Law',
                              [
                                'These Terms are governed by the laws of Bangladesh. Any disputes will be settled under the jurisdiction of courts in Bangladesh.',
                              ],
                            ),

                            _buildTermSection(
                              '10. Changes to Terms',
                              [
                                'We may update these Terms at any time. Updates will be posted in the App or on this page. Continued use means acceptance of revised Terms.',
                              ],
                            ),

                            _buildTermSection(
                              '11. Contact Us',
                              [
                                'For support or inquiries:',
                              ],
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      SizedboxSpaccing.height025(context),

                      // Contact Information in Separate Container
                      _buildContactInfo(),

                      SizedboxSpaccing.height025(context),

                      // Last Updated
                      _buildLastUpdated(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedboxSpaccing.height025(context),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02,),
      decoration: BoxDecoration(
        color: AppColors.button(context).withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.button(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.description,
              color: AppColors.whiteColor,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terms & Conditions',
                  style: AppTextStyles.textSize20(
                    context,
                    weight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Dinmajur Customer App',
                  style: AppTextStyles.textSize14(
                    context,
                    color: AppColors.subtitle(context),
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroText() {
    return Text(
      'These Terms & Conditions ("Terms") apply to the Dinmajur Customer App (hereby referred to as "Application"). By downloading, registering, or using the App, you agree to these Terms. If you do not agree, please stop using the App.',
      style: AppTextStyles.textSize14(
        context,
        weight: FontWeight.w400,
      ),
    );
  }

  Widget _buildTermSection(
      String title,
      List<String> points, {
        List<String>? subPoints,
        bool isLast = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 2),
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.button(context).withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.check,
                color: AppColors.whiteColor,
                size: 15,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.textSize18(
                  context,
                  weight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),

        // Points
        ...points.map((point) => Padding(
          padding: EdgeInsets.only(left: 32, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 6),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.button(context),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  point,
                  style: AppTextStyles.textSize14(
                    context,
                    weight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        )),

        // Sub Points (if any)
        if (subPoints != null && subPoints.isNotEmpty) ...[
          ...subPoints.map((subPoint) => Padding(
            padding: EdgeInsets.only(left: 48, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 6),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.subtitle(context),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subPoint,
                    style: AppTextStyles.textSize12(
                      context,
                      weight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],

        // Add divider between sections except for the last one
        if (!isLast) ...[
          SizedBox(height: 16),
          Divider(height: 1, color: AppColors.border(context)),
          SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Support',
            style: AppTextStyles.textSize18(
              context,
              weight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.email,
            label: 'Email',
            value: 'dinmajuri@gmail.com',
          ),
          Divider(height: 24, color: AppColors.border(context)),
          _buildContactItem(
            icon: Icons.phone,
            label: 'Phone',
            value: '+8801929600600',
          ),
          Divider(height: 24, color: AppColors.border(context)),
          _buildContactItem(
            icon: Icons.location_on,
            label: 'Address',
            value: 'Chattogram, Bangladesh',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.button(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.button(context),
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.textSize12(
                  context,
                  color: AppColors.subtitle(context),
                  weight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.textSize14(
                  context,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLastUpdated() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.containerBackground(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.update,
              size: 16,
              color: AppColors.subtitle(context),
            ),
            SizedBox(width: 6),
            Text(
              'Last Updated: October 2025',
              style: AppTextStyles.textSize12(
                context,
                color: AppColors.subtitle(context),
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}