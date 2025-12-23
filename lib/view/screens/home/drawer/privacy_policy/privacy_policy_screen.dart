import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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

    return Column(
      children: [
        // GestureDetector(
        //   onTap: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => NavigationScreen(initialIndex: 0),
        //       ),
        //     );
        //   },
        //   child: AppBarHeader("Privacy Policy"),
        // ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.02 ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Container with Border
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.containerBackground(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      width: 1,
                      color: AppColors.border(context)
                    )
                  ),
                  child: Column(
                    children: [
                      // Header Section
                      _buildHeaderSection(),

                      Divider(height: 1, color: AppColors.border(context)),

                      // Introduction and Privacy Content Container
                      Container(
                        padding: EdgeInsets.all(screenHeight * 0.02,),
                        decoration: BoxDecoration(
                          color: AppColors.containerBackground(context),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Effective Date
                            _buildEffectiveDate(),
                            SizedboxSpaccing.height015(context),

                            // Introduction
                            _buildIntroText(),
                            SizedboxSpaccing.height025(context),

                            // All Privacy Sections in One Container
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
                                  _buildPrivacySection(
                                    'Information We Collect',
                                    [],
                                    subSections: {
                                      'Registration Data': [
                                        'Phone number (verified via OTP)',
                                        'Optional profile details (name, address)',
                                      ],
                                      'Location Data': [
                                        'Live or pinned delivery address (latitude & longitude via Google Maps)',
                                      ],
                                      'Order Data': [
                                        'Order ID, product details, order history',
                                        'Assigned retailer & service provider details',
                                        'Delivery verification via OTP',
                                      ],
                                      'Device & Technical Data': [
                                        'Device type, operating system, IP address',
                                        'Usage statistics, crash reports, analytics',
                                      ],
                                      'Payment Data (if enabled in future)': [
                                        'We do not store card or bank details.',
                                        'Payments may be processed securely via trusted third-party gateways (e.g., bKash, Nagad, Rocket, Bank).',
                                      ],
                                    },
                                  ),

                                  _buildPrivacySection(
                                    'How We Use Information',
                                    [
                                      'We use collected data to:',
                                    ],
                                    subPoints: [
                                      'Verify your identity (OTP-based authentication)',
                                      'Process and manage customer orders',
                                      'Connect you with nearby retailers (within 1 km)',
                                      'Assign service providers for delivery',
                                      'Provide order tracking and updates',
                                      'Improve app performance and user experience',
                                      'Provide customer support and safety',
                                    ],
                                  ),

                                  _buildPrivacySection(
                                    'Information Sharing',
                                    [
                                      'We respect your privacy. Your data is shared only when necessary:',
                                    ],
                                    subPoints: [
                                      'With Retailers: To fulfill and confirm your order.',
                                      'With Service Providers: To deliver your order securely.',
                                      'With Third-Party Services: SMS/OTP providers, hosting, analytics, push notifications.',
                                      'For Legal Purposes: If required to comply with law or protect user safety.',
                                    ],
                                  ),

                                  _buildPrivacySection(
                                    'Location Data',
                                    [
                                      'Collected only with your consent.',
                                      'Used strictly for order placement and delivery.',
                                      'Never sold or shared with unauthorized parties.',
                                    ],
                                  ),

                                  _buildPrivacySection(
                                    'Data Retention',
                                    [
                                      'Account and order data are retained as long as your account is active, or as required by law.',
                                      'You may request account and data deletion at any time (subject to legal obligations).',
                                    ],
                                  ),

                                  _buildPrivacySection(
                                    'Security',
                                    [
                                      'We apply industry-standard safeguards (encryption, secure storage, restricted access). However, no system is 100% secure. Please keep your auth_login OTP/private details confidential.',
                                    ],
                                  ),

                                  _buildPrivacySection(
                                    'User Rights',
                                    [
                                      'You may request to:',
                                    ],
                                    subPoints: [
                                      'Access your personal data',
                                      'Update or correct information',
                                      'Delete your account and associated data',
                                    ],
                                    footer: 'Requests can be made via support@dinmajur.com.',
                                  ),

                                  _buildPrivacySection(
                                    'Children\'s Privacy',
                                    [
                                      'The service is not intended for children under 18. We do not knowingly collect information from children. If a child has registered, please contact us immediately.',
                                    ],
                                  ),

                                  _buildPrivacySection(
                                    'Changes to This Policy',
                                    [
                                      'We may update this Privacy Policy from time to time. Updates will be posted in the App and on this page. Continued use of the App means you accept the revised policy.',
                                    ],
                                  ),

                                  _buildPrivacySection(
                                    'Contact Us',
                                    [
                                      'For questions or support:',
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
          ),
        ),
      ],
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
              Icons.privacy_tip,
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
                  'Privacy Policy',
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

  Widget _buildEffectiveDate() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.button(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.button(context).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 14,
            color: AppColors.button(context),
          ),
          SizedBox(width: 6),
          Text(
            'Effective Date: September 10, 2025',
            style: AppTextStyles.textSize12(
              context,
              weight: FontWeight.w600,
              color: AppColors.button(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroText() {
    return Text(
      'This Privacy Policy applies to the Dinmajur Customer App (hereby referred to as "Application") for mobile devices that was created by Dinmajur (hereby referred to as "Service Provider") as a Free service. This service is intended for use "AS IS".\n\nThis Privacy Policy explains what information we collect, how we use it, and your rights when using the Application.',
      style: AppTextStyles.textSize14(
        context,
        weight: FontWeight.w400,
      ),
    );
  }

  Widget _buildPrivacySection(
      String title,
      List<String> points, {
        List<String>? subPoints,
        Map<String, List<String>>? subSections,
        String? footer,
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
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.button(context).withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.shield,
                color: AppColors.containerBackground(context),
                size: 12,
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
        SizedBox(height: 8),

        // Points
        if (points.isNotEmpty)
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
                    style: AppTextStyles.textSize14(
                      context,
                      weight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],

        // Sub Sections (if any)
        if (subSections != null && subSections.isNotEmpty) ...[
          SizedBox(height: 4),
          ...subSections.entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(left: 32, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: AppTextStyles.textSize14(
                      context,
                      weight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  ...entry.value.map((item) => Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 3),
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
                            item,
                            style: AppTextStyles.textSize14(
                              context,
                              weight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            );
          }),
        ],

        // Footer text (if any)
        if (footer != null) ...[
          Padding(
            padding: EdgeInsets.only(left: 32, top: 8),
            child: Text(
              footer,
              style: AppTextStyles.textSize14(
                context,
                weight: FontWeight.w500,
                color: AppColors.button(context),
              ),
            ),
          ),
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
              'Last Updated: September 2025',
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