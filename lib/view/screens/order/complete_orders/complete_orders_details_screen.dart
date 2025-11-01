import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/nearby_retailers_and_order_models/get_order_details_model.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_and_order_view_models/order_now_view_models/freelancer_rating_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_and_order_view_models/order_now_view_models/order_confirmed_getorderdetails_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class CompleteOrdersDetailsScreen extends StatefulWidget {
  final String orderId;

  const CompleteOrdersDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<CompleteOrdersDetailsScreen> createState() => _CompleteOrdersDetailsScreenState();
}

class _CompleteOrdersDetailsScreenState extends State<CompleteOrdersDetailsScreen> {
  int _currentStep = 3; // 0=Dinmajur, 1=Pickup, 2=Delivery, 3=Complete
  int _selectedRating = 0;
  bool _isRatingSubmitted = false; // Add this variable to track submission status

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final getOrderDetailsModel = Provider.of<GetOrderDetailsViewModel>(context, listen: false);
      getOrderDetailsModel.fetchOrderDetailsData(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)), (route) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.containerBackground(context),
        body: SafeArea(child: body()),
      ),
    );
  }

  Widget body() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(height: 60, child: AppBarHeader("Delivered")),
        ),
        Expanded(
          child: Consumer<GetOrderDetailsViewModel>(
            builder: (context, viewModel, child) {
              switch (viewModel.orderDetailsData.status) {
                case Status.LOADING:
                  return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45));
                case Status.ERROR:
                  return _buildErrorState();
                case Status.COMPLETED:
                  final data = viewModel.orderDetailsData.data?.data;
                  if (data == null) {
                    return Center(child: Text('No data available'));
                  }
                  return _buildContent(data);
                default:
                  return Center(child: Text('Something went wrong'));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedboxSpaccing.height02(context),
            Text(
              'Failed to load order details',
              style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedboxSpaccing.height03(context),
            ElevatedButton(
              onPressed: () {
                final viewModel = Provider.of<GetOrderDetailsViewModel>(context, listen: false);
                viewModel.fetchOrderDetailsData(widget.orderId);
              },
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.button(context), foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Data data) {
    final screenHeight = MediaQuery.of(context).size.height;
    final order = data.order;
    final retailer = data.retailer;
    final delivery = data.delivery;
    final customer = data.customer;
    final freelancer = data.freelancer;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(screenHeight * 0.02),
        child: Column(
          children: [
            _buildOrderProgress(context),
            SizedboxSpaccing.height02(context),
            _buildDeliveryCompletedCard(context, order),
            SizedboxSpaccing.height02(context),
            _buildCustomerInfo(context, customer, retailer, order, delivery, freelancer),
            SizedboxSpaccing.height02(context),
            _buildRatingSection(context, freelancer),
            SizedboxSpaccing.height02(context),
            _buildBackToHomeButton(context),
            SizedboxSpaccing.height02(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderProgress(BuildContext context) {
    List<String> steps = ['Dinmajur', 'Pickup', 'Delivery', 'Complete'];
    List<IconData> stepIcons = [FontAwesomeIcons.user, FontAwesomeIcons.box, FontAwesomeIcons.truck, FontAwesomeIcons.check];
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          width: screenWidth * 0.85,
          child: Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isEven) {
                int stepIndex = index ~/ 2;
                bool isActive = stepIndex <= _currentStep;

                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.button(context) : AppColors.containerBackground(context),
                    border: Border.all(width: 2, color: isActive ? AppColors.button(context) : AppColors.border(context)),
                  ),
                  child: Icon(stepIcons[stepIndex], color: isActive ? Colors.white : Colors.grey, size: 16),
                );
              } else {
                int lineIndex = (index - 1) ~/ 2;
                return Expanded(child: Container(height: 2, color: lineIndex < _currentStep ? AppColors.button(context) : AppColors.border(context)));
              }
            }),
          ),
        ),
        SizedboxSpaccing.height01(context),
        Container(
          width: screenWidth * 0.92,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              bool isActive = index <= _currentStep;
              bool isCurrent = index == _currentStep;
              return Expanded(
                child: Container(
                  height: 30,
                  child: Center(
                    child: Text(
                      steps[index],
                      style: AppTextStyles.textSize12(context, weight: isCurrent ? FontWeight.w600 : FontWeight.w400, color: isActive ? AppColors.textPrimary(context) : AppColors.subtitle(context)),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryCompletedCard(BuildContext context, Order? order) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border(context), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: AppColors.border(context), shape: BoxShape.circle),
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
                child: Icon(Icons.check, color: Colors.white, size: 20),
              ),
            ),
          ),
          SizedboxSpaccing.height02(context),
          Text('Delivery Completed', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
          SizedboxSpaccing.height01(context),
          Text(
            'Thank you for choosing our bazar delivery\nservice! We look forward to serving you again.',
            textAlign: TextAlign.center,
            style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(BuildContext context, Customer? customer, Retailer? retailer, Order? order, Delivery? delivery, Freelancer? freelancer) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.oceanGreenColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.textPrimary(context), borderRadius: BorderRadius.circular(8)),
                      child: Icon(FontAwesomeIcons.store, color: AppColors.containerBackground(context), size: 16),
                    ),
                    SizedboxSpaccing.width03(context),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${retailer?.businessName ?? 'N/A'}",
                            style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${retailer?.businessType ?? 'N/A'}',
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedboxSpaccing.width02(context),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.textFieldFill(context), borderRadius: BorderRadius.circular(8)),
                child: Text('Order #${order?.id?.substring(order.id!.length - 6) ?? 'N/A'}', style: AppTextStyles.textSize12(context, weight: FontWeight.w400)),
              ),
            ],
          ),
          SizedboxSpaccing.height02(context),

          // Freelancer Info Section
          if (freelancer != null)
            Container(
              padding: EdgeInsets.all(screenHeight * 0.015),
              decoration: BoxDecoration(
                color: AppColors.textFieldFill(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.button(context)),
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                      SizedboxSpaccing.width03(context),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${freelancer.firstName ?? ''} ${freelancer.lastName ?? ''}'.trim().isEmpty ? 'N/A' : '${freelancer.firstName ?? ''} ${freelancer.lastName ?? ''}'.trim(),
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.button(context)),
                          ),
                          Text(
                            'Delivery Person',
                            style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (delivery?.deliveredAt != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Delivered at',
                          style: AppTextStyles.textSize10(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                        ),
                        Text(
                          _formatDeliveredTime(delivery!.deliveredAt!),
                          style: AppTextStyles.textSize12(context, weight: FontWeight.w500, color: AppColors.button(context)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          SizedboxSpaccing.height02(context),
          GestureDetector(
            onTap: () {
              // Add download receipt functionality here
              Utils.flushBarErrorMessage('Download feature coming soon', context);
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.containerBackground(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(width: 1, color: AppColors.border(context)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.download, color: AppColors.textPrimary(context), size: 15),
                  SizedboxSpaccing.width03(context),
                  Text('Download Receipt', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDeliveredTime(DateTime deliveredAt) {
    DateTime bdTime = deliveredAt.add(Duration(hours: 6));
    return DateFormat('hh:mm a').format(bdTime);
  }

  Widget _buildRatingSection(BuildContext context, Freelancer? freelancer) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<PatchFreelancerRatingViewModel>(
      builder: (context, freelancerRatingModel, child) {
        return Container(
          padding: EdgeInsets.all(screenHeight * 0.02),
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('How was your delivery?', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
              SizedboxSpaccing.height02(context),
              // Rating stars (5 icons)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final isSelected = _selectedRating >= index + 1;
                  return GestureDetector(
                    onTap: (_isRatingSubmitted || freelancerRatingModel.createFreelancerRatingLoading)
                        ? null
                        : () async {
                      if (freelancer == null || freelancer.id == null) {
                        Utils.flushBarErrorMessage('Freelancer data not available', context);
                        return;
                      }

                      setState(() {
                        _selectedRating = index + 1;
                      });

                      print("Rating $_selectedRating");
                      print("FreelancerID--- ${freelancer.id}");
                      print("FreelancerID--- ${freelancer.phone}");

                      if (_selectedRating == 0) {
                        Utils.flushBarErrorMessage('Please select a rating', context);
                        return;
                      }

                      // Prevent double submission
                      if (_isRatingSubmitted) {
                        Utils.flushBarErrorMessage('Rating already submitted', context);
                        return;
                      }

                      Map<String, dynamic> fields = {"rating": _selectedRating};

                      await freelancerRatingModel.FreelancerRatingPatchApi(context, freelancer.id!, fields);

                      // If success, mark as submitted
                      if (context.mounted) {
                        setState(() {
                          _isRatingSubmitted = true;
                        });
                      }
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 250),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.amber.withOpacity(0.9) : AppColors.containerBackground(context),
                        border: Border.all(width: 2, color: isSelected ? Colors.amber : AppColors.border(context)),
                      ),
                      child: Icon(Icons.star_rounded, color: isSelected ? Colors.white : Colors.grey, size: 28),
                    ),
                  );
                }),
              ),

              // Rating success message
              if (_isRatingSubmitted) ...[
                SizedboxSpaccing.height02(context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Rating submitted successfully!',
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: Colors.green),
                    ),
                  ],
                ),
              ],

              // Loading indicator
              if (freelancerRatingModel.createFreelancerRatingLoading) ...[SizedboxSpaccing.height02(context), LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 30)],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackToHomeButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NavigationScreen(initialIndex: 0)), (route) => false);
      },
      child: Container(
        width: screenWidth * 0.8,
        height: 50,
        decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.home, color: Colors.white, size: 15),
            SizedboxSpaccing.width03(context),
            Text(
              'Back to Home',
              style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
