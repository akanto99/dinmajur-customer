import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/components/pdf_reciept_generator_auto_open_download/pdf_reciept_generator_auto_open_download.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_and_order_view_models/order_now_view_models/freelancer_rating_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_and_order_view_models/order_now_view_models/order_confirmed_getorderdetails_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:dinmajur_customer/model/home_models/nearby_retailers_and_order_models/get_order_details_model.dart';

class DeliverdScreen extends StatefulWidget {
  final String orderId;

  const DeliverdScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<DeliverdScreen> createState() => _DeliverdScreenState();
}

class _DeliverdScreenState extends State<DeliverdScreen> {
  int _currentStep = 3;
  int _selectedRating = 0;
  bool _isRatingSubmitted = false;

  @override
  void initState() {
    super.initState();
    print(widget.orderId);
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
            _buildCustomerInfo(context, customer, retailer, order, delivery, freelancer, data), // ✅ PASS data HERE
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

  // ✅ UPDATED METHOD - Added Data parameter
  Widget _buildCustomerInfo(
      BuildContext context,
      Customer? customer,
      Retailer? retailer,
      Order? order,
      Delivery? delivery,
      Freelancer? freelancer,
      Data data, // ✅ ADD THIS PARAMETER
      ) {
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
                        child: ClipOval(
                          child: freelancer.profilePicture?.url != null && freelancer.profilePicture!.url!.isNotEmpty
                              ? Image.network(freelancer.profilePicture!.url!, width: 40, height: 40, fit: BoxFit.cover)
                              : Icon(Icons.person, color: Colors.white, size: 20),
                        ),
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

          // ✅ DOWNLOAD RECEIPT BUTTON
          GestureDetector(
            onTap: () async {
              try {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.containerBackground(context),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: LoadingAnimationWidget.progressiveDots(
                        color: AppColors.button(context),
                        size: 45,
                      ),
                    ),
                  ),
                );

                // ✅ Generate PDF - Now 'data' is available
                final file = await ReceiptPdfGenerator.generateAndDownloadReceipt(data);

                // Close loading dialog
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }

                if (file != null) {
                  // Show success message
                  Utils.flushBarSuccessMessage(
                    'Receipt downloaded successfully!',
                    context,
                  );

                  // ✅ Open the PDF file
                  await OpenFile.open(file.path);
                } else {
                  Utils.flushBarErrorMessage(
                    'Failed to generate receipt',
                    context,
                  );
                }
              } catch (e) {
                // Close loading dialog if open
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }

                print('Error: $e');
                Utils.flushBarErrorMessage(
                  'Error: ${e.toString()}',
                  context,
                );
              }
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
                  Icon(
                    FontAwesomeIcons.download,
                    color: AppColors.textPrimary(context),
                    size: 15,
                  ),
                  SizedboxSpaccing.width03(context),
                  Text(
                    'Download Receipt',
                    style: AppTextStyles.textSize16(
                      context,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  String _formatDeliveredTime(DateTime deliveredAt) {
    DateTime bdTime = deliveredAt.add(Duration(hours: 6));
    return DateFormat('hh:mm a').format(bdTime);
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