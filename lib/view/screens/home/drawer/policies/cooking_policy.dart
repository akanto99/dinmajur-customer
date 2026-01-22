import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:flutter/material.dart';

class CookiesPolicyScreen extends StatefulWidget {
  const CookiesPolicyScreen({super.key});

  @override
  State<CookiesPolicyScreen> createState() => _CookiesPolicyScreenState();
}

class _CookiesPolicyScreenState extends State<CookiesPolicyScreen> {
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
      padding: EdgeInsets.all(screenWidth * 0.02),
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

                Divider(height: 1, color: AppColors.border(context)),

                // Introduction and Content Container
                Container(
                  padding: EdgeInsets.all(screenHeight * 0.02),
                  decoration: BoxDecoration(
                    color: AppColors.containerBackground(context),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(
                      width: 1,
                      color: AppColors.border(context),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Introduction
                      _buildIntroText(),
                      SizedboxSpaccing.height025(context),

                      // All Policy Sections in One Container
                      Container(
                        padding: EdgeInsets.all(screenHeight * 0.015),
                        decoration: BoxDecoration(
                          color: AppColors.containerBackground(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border(context)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPolicySection(
                              '1. What Are Cookies?',
                              [
                                'Cookies are small text files stored on your device when you visit a website. They help us recognize you, remember your preferences, and improve our services.',
                              ],
                            ),

                            _buildPolicySection(
                              '2. Types of Cookies We Use',
                              [
                                'Essential Cookies: Necessary for the basic functionality of our website.',
                                'Performance Cookies: Help us understand user behavior and improve our services.',
                                'Functional Cookies: Allow us to remember user preferences and settings.',
                                'Advertising Cookies: Used to show personalized ads based on your interests.',
                              ],
                            ),

                            _buildPolicySection(
                              '3. How We Use Cookies',
                              [
                                'Keep you logged in and improve security.',
                                'Store your preferences like language and location settings.',
                                'Analyze user activity and enhance website performance.',
                                'Provide personalized job recommendations and ads.',
                              ],
                            ),

                            _buildPolicySection(
                              '4. Managing Your Cookie Preferences',
                              [
                                'You can manage or disable cookies through your browser settings. However, disabling certain cookies may affect your experience on our platform.',
                              ],
                              subPoints: [
                                'View stored cookies.',
                                'Delete cookies from your device.',
                                'Set preferences for cookie usage.',
                              ],
                            ),

                            _buildPolicySection(
                              '5. Third-Party Cookies',
                              [
                                'We may allow third-party services (e.g., Google Analytics, advertising networks) to place cookies on your device. These cookies help deliver relevant ads and analyze site performance. We do not control these third-party cookies.',
                              ],
                            ),

                            _buildPolicySection(
                              '6. Changes to This Cookies Policy',
                              [
                                'We may update this policy from time to time. Any changes will be posted on this page, and we encourage you to review it periodically.',
                              ],
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      SizedboxSpaccing.height025(context),

                      // Contact Information in Separate Container
                      _buildContactInfo(),
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
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
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
              Icons.cookie,
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
                  'Cookies Policy',
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
      'At Dinmajur, we use cookies and similar tracking technologies to enhance your experience on our platform. This Cookies Policy explains how we use cookies, what types of cookies we use, and how you can manage your preferences.',
      style: AppTextStyles.textSize14(
        context,
        weight: FontWeight.w400,
      ),
    );
  }

  Widget _buildPolicySection(
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

}