import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:flutter/material.dart';

class RefundPolicyScreen extends StatefulWidget {
  const RefundPolicyScreen({super.key});

  @override
  State<RefundPolicyScreen> createState() => _RefundPolicyScreenState();
}

class _RefundPolicyScreenState extends State<RefundPolicyScreen> {
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
                              '1. Eligibility for Refund',
                              'Refunds may be applicable under the following conditions:',
                              applicablePoints: [
                                'If the service provider fails to arrive at the scheduled time without prior notice.',
                                'If the service is cancelled by Dinmajur due to unavailability of a service provider.',
                                'If the service delivered is significantly different from what was booked, subject to verification.',
                                'Refund requests must be made within 24 hours of the scheduled service time.',
                              ],
                              notApplicableTitle: 'Refunds are not applicable if:',
                              notApplicablePoints: [
                                'The service has already been completed successfully.',
                                'The customer is unavailable at the service location.',
                                'Incorrect address or contact details were provided by the customer.',
                                'The service was cancelled by the customer after confirmation.',
                              ],
                            ),

                            _buildPolicySection(
                              '2. Refund Request Process',
                              'To request a refund, please contact our customer support team with your Order ID, service details, and reason for the refund.',
                              contactPoints: [
                                'Customer Care: 01929600600',
                                'Website: dinmajur.com',
                              ],
                              additionalInfo:
                              'Our team will review your request and notify you of the approval or rejection.',
                            ),

                            _buildPolicySection(
                              '3. Refund Processing Time',
                              null,
                              simplePoints: [
                                'Approved refunds will be processed to the original payment method (Bank, Card, or MFS).',
                                'Refunds are usually completed within 5 to 7 working days after approval.',
                                'Processing time may vary depending on the bank or mobile financial service provider.',
                              ],
                            ),

                            _buildPolicySection(
                              '4. Late or Missing Refunds',
                              null,
                              simplePoints: [
                                'Check your bank or MFS account again.',
                                'Contact your bank, card issuer, or MFS provider.',
                                'If the issue persists, contact Dinmajur customer support for assistance.',
                              ],
                            ),

                            _buildPolicySection(
                              '5. Changes to This Refund Policy',
                              null,
                              simplePoints: [
                                'Dinmajur Platform Service reserves the right to update or modify this Refund Policy at any time.',
                                'Any changes will take effect immediately upon being published on our website or app.',
                              ],
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      SizedboxSpaccing.height025(context),

                      // Agreement Note
                      _buildAgreementNote(),

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
              Icons.payment,
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
                  'Refund Policy',
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
      'Thank you for choosing Dinmajur Platform Service. We value your trust and aim to ensure customer satisfaction. Please read the following Refund Policy carefully before placing an order on our platform.',
      style: AppTextStyles.textSize14(
        context,
        weight: FontWeight.w400,
      ),
    );
  }

  Widget _buildPolicySection(
      String title,
      String? description, {
        List<String>? applicablePoints,
        String? notApplicableTitle,
        List<String>? notApplicablePoints,
        List<String>? contactPoints,
        String? additionalInfo,
        List<String>? simplePoints,
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

        // Description
        if (description != null)
          Padding(
            padding: EdgeInsets.only(left: 32, bottom: 12),
            child: Text(
              description,
              style: AppTextStyles.textSize14(
                context,
                weight: FontWeight.w400,
              ),
            ),
          ),

        // Applicable Points
        if (applicablePoints != null)
          ...applicablePoints.map((point) => Padding(
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

        // Not Applicable Title and Points
        if (notApplicableTitle != null) ...[
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(left: 32, bottom: 8),
            child: Text(
              notApplicableTitle,
              style: AppTextStyles.textSize14(
                context,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ],

        if (notApplicablePoints != null)
          ...notApplicablePoints.map((point) => Padding(
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

        // Contact Points
        if (contactPoints != null) ...[
          SizedBox(height: 8),
          ...contactPoints.map((point) => Padding(
            padding: EdgeInsets.only(left: 32, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  point.contains('Customer Care')
                      ? Icons.phone
                      : Icons.language,
                  size: 16,
                  color: AppColors.button(context),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    point,
                    style: AppTextStyles.textSize14(
                      context,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],

        // Additional Info
        if (additionalInfo != null)
          Padding(
            padding: EdgeInsets.only(left: 32, top: 12),
            child: Text(
              additionalInfo,
              style: AppTextStyles.textSize14(
                context,
                weight: FontWeight.w400,
              ),
            ),
          ),

        // Simple Points
        if (simplePoints != null)
          ...simplePoints.map((point) => Padding(
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

        // Add divider between sections except for the last one
        if (!isLast) ...[
          SizedBox(height: 16),
          Divider(height: 1, color: AppColors.border(context)),
          SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildAgreementNote() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.button(context).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.button(context).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.button(context),
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'By placing an order through Dinmajur Platform Service, you agree to and accept the terms of this Refund Policy.',
              style: AppTextStyles.textSize12(
                context,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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