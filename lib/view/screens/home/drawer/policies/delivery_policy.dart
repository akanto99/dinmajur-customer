import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:flutter/material.dart';

class DeliveryPolicyScreen extends StatefulWidget {
  const DeliveryPolicyScreen({super.key});

  @override
  State<DeliveryPolicyScreen> createState() => _DeliveryPolicyScreenState();
}

class _DeliveryPolicyScreenState extends State<DeliveryPolicyScreen> {
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
                              '1. Order Processing & Service Confirmation',
                              [
                                'Service requests are usually confirmed within 30 minutes to 24 hours after booking, depending on service type and availability.',
                                'Once confirmed, a service provider (worker/partner) is assigned to your order.',
                              ],
                            ),

                            _buildPolicySection(
                              '2. Service Delivery Method',
                              [
                                'Dinmajur primarily provides doorstep services, where trained service providers visit the customer\'s location.',
                                'Some services may be delivered online or via phone, if applicable.',
                              ],
                            ),

                            _buildPolicySection(
                              '3. Service Location & Address Accuracy',
                              [
                                'Customers must provide a complete and accurate service address, including contact number and landmarks.',
                                'Dinmajur is not responsible for service delays or failures caused by incorrect or incomplete address details.',
                              ],
                            ),

                            _buildPolicySection(
                              '4. Service Area & Availability',
                              [
                                'Services are available only in selected locations covered by Dinmajur.',
                                'Availability may vary based on time, location, weather, or service provider capacity.',
                              ],
                            ),

                            _buildPolicySection(
                              '5. Service Completion & Confirmation',
                              [
                                'Once the service is completed, it will be marked as delivered/completed in the Dinmajur system.',
                                'Customers may receive confirmation via SMS, app notification, or phone call.',
                              ],
                            ),

                            _buildPolicySection(
                              '6. Delays or Rescheduling',
                              [
                                'While we aim to deliver services on time, delays may occur due to traffic, weather conditions, emergencies, or unforeseen circumstances.',
                                'Customers will be informed and supported accordingly.',
                              ],
                            ),

                            _buildPolicySection(
                              '7. Non-Delivery or Customer Unavailability',
                              [
                                'If service cannot be completed due to customer unavailability or incorrect details, the order may be cancelled or rescheduled.',
                                'Additional charges may apply for repeat visits, depending on the service type.',
                              ],
                            ),

                            _buildPolicySection(
                              '8. Support & Contact Information',
                              [
                                'If you have any questions about this Delivery Policy, please contact us through the channels provided below.',
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
              Icons.local_shipping,
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
                  'Delivery Policy',
                  style: AppTextStyles.textSize20(
                    context,
                    weight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Dinmajur Platform Service',
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
      'Thank you for choosing Dinmajur Platform Service as your trusted on-demand service platform. This Delivery Policy explains how our services are scheduled and delivered. By placing an order through Dinmajur, you agree to the terms outlined below.',
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
            icon: Icons.phone,
            label: 'Customer Care',
            value: '01929600600',
          ),
          Divider(height: 24, color: AppColors.border(context)),
          _buildContactItem(
            icon: Icons.language,
            label: 'Website',
            value: 'dinmajur.com',
          ),
          Divider(height: 24, color: AppColors.border(context)),
          _buildContactItem(
            icon: Icons.phone_android,
            label: 'Mobile App',
            value: 'Dinmajur Customer App',
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