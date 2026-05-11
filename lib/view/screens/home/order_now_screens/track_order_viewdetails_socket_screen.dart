import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/components/payment_method/payment_method_component.dart';
import 'package:dinmajur_customer/configs/res/components/section_header/section_header.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/home_models/socket_home_model/socket_get_all_orders_model/socket_orderdetails_model.dart';
import 'package:dinmajur_customer/socket_connection_model/screens_sockets/home_sceens_socket/get_all_orders_socket/socket_order_view_details.dart';
import 'package:dinmajur_customer/socket_connection_model/socket_provider_services/socket_manager.dart';
import 'package:dinmajur_customer/view/navigation_bar.dart';
import 'package:dinmajur_customer/view/screens/home/order_now_screens/helper_widget/dual_terms&conditons_widget.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/grocery_order_view_model/track_order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackOrderViewdetailsSocketScreen extends StatefulWidget {
  final String orderId;
  const TrackOrderViewdetailsSocketScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<TrackOrderViewdetailsSocketScreen> createState() => _TrackOrderViewdetailsSocketScreenState();
}

class _TrackOrderViewdetailsSocketScreenState extends State<TrackOrderViewdetailsSocketScreen> with RouteAware {
  // One fresh VM per screen push — owns its own lifecycle
  late final TrackOrderViewModel _vm;
  // RouteObserver to detect when the user pops back to this screen
  static final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

  @override
  void initState() {
    super.initState();
    _vm = TrackOrderViewModel(orderId: widget.orderId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initializeScreen();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to RouteObserver — safe to call multiple times
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  Future<void> _initializeScreen() async {
    await _vm.initialize(
      context: context,
      orderDetailsProvider: Provider.of<OrderDetailsSocketProvider>(context, listen: false),
      // ✅ Use SocketManager (singleton) — no more SocketProvider
      socketManager: Provider.of<SocketManager>(context, listen: false),
    );
  }

  // ── RouteAware: user pops back to this screen ─────────────────────────────────
  @override
  void didPopNext() {
    // User returned from a screen pushed on top of this one
    // (e.g., payment screen). Silently refresh data.
    if (_vm.isInitialized) {
      debugPrint('🔄 [SCREEN] Returned to screen — silent refresh');
      _vm.handleRefresh(context: context);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TrackOrderViewModel>.value(
      value: _vm,
      child: Scaffold(
        backgroundColor: AppColors.containerBackground(context),
        body: SafeArea(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NavigationScreen(initialIndex: 0))),
                child: SizedBox(height: 60, child: AppBarHeader('Track Order Details')),
              ),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<OrderDetailsSocketProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.orderDetailsModel == null) {
          return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45));
        }
        if (provider.error != null && provider.orderDetailsModel == null) {
          return _buildErrorState(provider.error!);
        }
        if (provider.orderDetailsModel != null) {
          return _buildOrderDetailsContent(provider.orderDetailsModel!);
        }
        return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 45));
      },
    );
  }

  Widget _buildErrorState(String error) {
    return RefreshIndicator(
      onRefresh: () => _vm.handleRefresh(context: context),
      color: AppColors.button(context),
      backgroundColor: AppColors.containerBackground(context),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FontAwesomeIcons.boxOpen, size: 50, color: Colors.red),
                  SizedboxSpaccing.height02(context),
                  Text(
                    'Unable to Load Order',
                    style: AppTextStyles.textSize18(context, weight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedboxSpaccing.height01(context),
                  Text(
                    error,
                    style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                    textAlign: TextAlign.center,
                  ),
                  SizedboxSpaccing.height03(context),
                  ElevatedButton.icon(
                    onPressed: () => _vm.handleRefresh(context: context),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.button(context), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Main Content ──────────────────────────────────────────────────────────────
  Widget _buildOrderDetailsContent(OrderDetailsModel model) {
    final screenHeight = MediaQuery.of(context).size.height;
    final order = model.order!;
    final retailer = model.retailer;
    final delivery = model.delivery;
    final customer = model.customer;
    final freelancer = model.freelancer;
    final payment = model.payment!;

    final bool isPending = delivery?.status?.toUpperCase() == 'PENDING';
    final bool isPickedUp = delivery?.status?.toUpperCase() == 'PICKED_UP';
    final bool isArriveDestination = delivery?.status?.toUpperCase() == 'ARRIVED_DESTINATION';

    return RefreshIndicator(
      onRefresh: () => _vm.handleRefresh(context: context),
      color: AppColors.button(context),
      backgroundColor: AppColors.containerBackground(context),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(screenHeight * 0.02),
          child: Column(
            children: [
              _buildOrderProgress(delivery?.status),
              SizedboxSpaccing.height02(context),
              if (isPending) ...[_buildConfirmationCard(), SizedboxSpaccing.height02(context)],
              _buildCustomerInfo(customer, retailer, order, delivery, freelancer),
              SizedboxSpaccing.height02(context),
              if (!isPending) ...[_buildContactSection(freelancer), SizedboxSpaccing.height02(context)],
              _buildCustomerOrderItems(order.items),
              SizedboxSpaccing.height02(context),
              if (order.customerNote != null && order.customerNote!.isNotEmpty) ...[_buildCustomerNotes(order.customerNote!), SizedboxSpaccing.height02(context)],
              if (isPickedUp || isArriveDestination) ...[
                _buildDeliveryItemsSection(order.items),
                SizedboxSpaccing.height02(context),
                _buildTotalSection(order),
                SizedboxSpaccing.height02(context),
                _buildPaymentStatusBanner(payment),

                // Only show payment method + pay button if not yet paid
                if (payment.paymentType != 'CASH_ON_DELIVERY' && payment.paymentType != 'ONLINE') ...[
                  _buildPaymentMethodSection(),
                  SizedboxSpaccing.height02(context),
                  _buildDualTermsCheckbox(),
                  SizedboxSpaccing.height02(context),
                  _buildPayNowButton(order, payment, delivery!),
                  SizedboxSpaccing.height02(context),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Order Progress ────────────────────────────────────────────────────────────
  Widget _buildOrderProgress(String? deliveryStatus) {
    final steps = ['Dinmajur', 'Pickup', 'Delivery', 'Complete'];
    final stepIcons = [FontAwesomeIcons.user, FontAwesomeIcons.box, FontAwesomeIcons.truck, FontAwesomeIcons.check];
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isPending = deliveryStatus?.toUpperCase() == 'PENDING';

    if (isPending) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange),
        ),
        child: Row(
          children: [
            const Icon(Icons.hourglass_empty, color: Colors.orange, size: 24),
            SizedboxSpaccing.width03(context),
            Expanded(
              child: Text(
                'Order is pending. Waiting for freelancer acceptance...',
                style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    final int currentStep = _vm.getCurrentStepFromStatus(deliveryStatus);

    return Column(
      children: [
        SizedBox(
          width: screenWidth * 0.8,
          child: Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isEven) {
                final stepIndex = index ~/ 2;
                final bool isActive = stepIndex <= currentStep;
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.button(context) : AppColors.containerBackground(context),
                    border: Border.all(width: 1, color: isActive ? AppColors.button(context) : AppColors.border(context)),
                  ),
                  child: Icon(stepIcons[stepIndex], color: isActive ? Colors.white : Colors.grey, size: 16),
                );
              } else {
                final lineIndex = (index - 1) ~/ 2;
                return Expanded(child: Container(height: 2, color: lineIndex < currentStep ? AppColors.button(context) : AppColors.border(context)));
              }
            }),
          ),
        ),
        SizedboxSpaccing.height01(context),
        SizedBox(
          width: screenWidth * 0.92,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final bool isActive = index <= currentStep;
              final bool isCurrent = index == currentStep;
              return Expanded(
                child: SizedBox(
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

  // ── Customer Info Card ────────────────────────────────────────────────────────
  Widget _buildCustomerInfo(Customer? customer, Retailer? retailer, Order order, Delivery? delivery, Freelancer? freelancer) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(16),
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
                            customer?.fullName ?? 'N/A',
                            style: AppTextStyles.textSize18(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Under: ${retailer?.businessName ?? 'N/A'}',
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.textFieldFill(context), borderRadius: BorderRadius.circular(8)),
                child: Text('Order #${order.id?.substring(order.id!.length - 6) ?? 'N/A'}', style: AppTextStyles.textSize12(context, weight: FontWeight.w400)),
              ),
            ],
          ),
          SizedboxSpaccing.height02(context),
          if (freelancer != null && delivery?.status?.toUpperCase() != 'PENDING') ...[
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
                              : const Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                      ),
                      SizedboxSpaccing.width03(context),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${freelancer.firstName ?? ''} ${freelancer.lastName ?? ''}'.trim(),
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.buttonTextColor(context)),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                              SizedboxSpaccing.width01(context),
                              Text('${freelancer.rating?.toStringAsFixed(1) ?? 'N/A'}', style: AppTextStyles.textSize12(context, weight: FontWeight.w400)),
                              SizedboxSpaccing.width02(context),
                              Text(
                                '• ${freelancer.totalOrders ?? 0} orders',
                                style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (freelancer.acceptedAt != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Accepted at',
                          style: AppTextStyles.textSize10(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                        ),
                        Text(
                          _vm.formatAcceptedTime(freelancer.acceptedAt!),
                          style: AppTextStyles.textSize12(context, weight: FontWeight.w500, color: AppColors.button(context)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedboxSpaccing.height02(context),
          ],
          Row(
            children: [
              Text('Budget: ', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
              // Text('৳${order.budget ?? 0}',
              //     style: AppTextStyles.textSize14(context,
              //         weight: FontWeight.w400)),
            ],
          ),
          SizedboxSpaccing.height01(context),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _dot(),
                    SizedboxSpaccing.width02(context),
                    Text('By: ${_vm.formatTime(order.createdAt)}', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                  ],
                ),
              ),
              Row(
                children: [
                  _dot(),
                  SizedboxSpaccing.width02(context),
                  Text(_vm.formatDate(order.createdAt), style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                ],
              ),
            ],
          ),
          SizedboxSpaccing.height02(context),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 22,
                width: 20,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Icon(Icons.location_on, size: 16, color: AppColors.button(context)),
                ),
              ),
              SizedboxSpaccing.width02(context),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Address',
                      style: AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.buttonTextColor(context)),
                    ),
                    SizedboxSpaccing.height005(context),
                    Text(
                      delivery?.destinationFullAddress ?? 'No address available',
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                    ),
                    SizedboxSpaccing.height005(context),
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.car, size: 12, color: AppColors.subtitle(context)),
                        SizedboxSpaccing.width02(context),
                        Text(
                          '${delivery?.distance ?? 'N/A'} from Store',
                          style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.buttonTextColor(context)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Contact Section ───────────────────────────────────────────────────────────
  Widget _buildContactSection(Freelancer? freelancer) {
    final screenHeight = MediaQuery.of(context).size.height;
    final String freelancerPhone = freelancer?.phone ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact With Delivery Person', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
        SizedboxSpaccing.height01(context),
        Divider(height: 1, color: AppColors.border(context)),
        SizedboxSpaccing.height02(context),
        Container(
          padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02, vertical: screenHeight * 0.015),
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
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.button(context)),
                    child: ClipOval(
                      child: freelancer?.profilePicture?.url != null && freelancer!.profilePicture!.url!.isNotEmpty
                          ? Image.network(
                              freelancer.profilePicture!.url!,
                              width: 34,
                              height: 34,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 20),
                            )
                          : const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ),
                  SizedboxSpaccing.width03(context),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${freelancer?.firstName ?? ''} ${freelancer?.lastName ?? ''}'.trim().isEmpty ? 'N/A' : '${freelancer?.firstName ?? ''} ${freelancer?.lastName ?? ''}'.trim(),
                        style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.buttonTextColor(context)),
                      ),
                      Text(freelancerPhone.isEmpty ? 'N/A' : freelancerPhone, style: AppTextStyles.textSize12(context, weight: FontWeight.w400)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: freelancerPhone.isNotEmpty && freelancerPhone != 'N/A' ? () => _openWhatsApp(freelancerPhone) : null,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.border(context)),
                      child: Icon(Icons.message, color: AppColors.textPrimary(context), size: 18),
                    ),
                  ),
                  SizedboxSpaccing.width02(context),
                  GestureDetector(
                    onTap: freelancerPhone.isNotEmpty && freelancerPhone != 'N/A' ? () => _makePhoneCall(freelancerPhone) : null,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.border(context)),
                      child: Icon(Icons.call, color: AppColors.textPrimary(context), size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Customer Order Items ──────────────────────────────────────────────────────
  Widget _buildCustomerOrderItems(List<Item>? items) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Customer Order Items (${items.length})', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
        SizedboxSpaccing.height01(context),
        Divider(height: 1, color: AppColors.border(context)),
        SizedboxSpaccing.height02(context),
        Container(
          padding: EdgeInsets.all(screenHeight * 0.02),
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(item.name ?? 'N/A', style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
                      ),
                      Text(
                        '${item.quantity ?? 0} ${item.unit ?? ''}',
                        style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                      ),
                    ],
                  ),
                  if (index < items.length - 1) ...[SizedboxSpaccing.height01(context), Divider(height: 1, color: AppColors.border(context)), SizedboxSpaccing.height01(context)],
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── Customer Notes ────────────────────────────────────────────────────────────
  Widget _buildCustomerNotes(String customerNote) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.solidMessage, size: 18, color: AppColors.textPrimary(context)),
                SizedboxSpaccing.width02(context),
                Text('Customer Notes', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border(context)),
          Padding(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenHeight * 0.02),
              decoration: BoxDecoration(
                color: AppColors.textFieldFill(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1, color: AppColors.border(context)),
              ),
              child: Text(
                customerNote,
                style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.textPrimary(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Delivery Items Section ────────────────────────────────────────────────────
  Widget _buildDeliveryItemsSection(List<Item>? items) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivery Items', style: AppTextStyles.textSize18(context, weight: FontWeight.w500)),
        SizedboxSpaccing.height01(context),
        Divider(height: 1, color: AppColors.border(context)),
        SizedboxSpaccing.height02(context),
        Container(
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(screenHeight * 0.015),
                decoration: BoxDecoration(
                  color: AppColors.containerBackground(context),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text('Item Name', style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
                    ),
                    Expanded(
                      child: Text(
                        'Weight/Pcs/Qty',
                        style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Price',
                        style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.border(context)),
              ...List.generate(items.length, (index) {
                final item = items[index];
                final bool isNotFound = item.status?.toLowerCase() == 'not_found' || item.totalPrice == null || item.totalPrice == 0;

                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.015, vertical: screenHeight * 0.012),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  item.name ?? 'N/A',
                                  style: AppTextStyles.textSize14(
                                    context,
                                    weight: FontWeight.w400,
                                  ).copyWith(decoration: isNotFound ? TextDecoration.lineThrough : null, decorationColor: isNotFound ? Colors.red : null, decorationThickness: isNotFound ? 2.0 : null),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${item.quantity ?? 0} ${item.unit ?? ''}',
                                  style: AppTextStyles.textSize14(
                                    context,
                                    weight: FontWeight.w400,
                                    color: AppColors.subtitle(context),
                                  ).copyWith(decoration: isNotFound ? TextDecoration.lineThrough : null, decorationColor: isNotFound ? Colors.red : null, decorationThickness: isNotFound ? 2.0 : null),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  isNotFound ? '' : '৳${item.totalPrice ?? 0}',
                                  style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Dinmajur's comment:",
                            style: AppTextStyles.textSize14(context, weight: FontWeight.w400).copyWith(decoration: TextDecoration.underline, decorationThickness: 1.0),
                          ),
                          Text(
                            (item.comment == null || item.comment!.isEmpty) ? 'N/A' : item.comment!,
                            style: AppTextStyles.textSize12(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
                          ),
                          SizedboxSpaccing.height005(context),
                        ],
                      ),
                    ),
                    if (index < items.length - 1) Divider(height: 1, color: AppColors.border(context), indent: screenHeight * 0.015, endIndent: screenHeight * 0.015),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ── Confirmation Card ─────────────────────────────────────────────────────────
  Widget _buildConfirmationCard() {
    return Container(
      height: 132,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.containerBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: AppColors.border(context)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Order Confirmed!',
            style: AppTextStyles.textSize24(context, weight: FontWeight.w600, color: AppColors.button(context)),
          ),
          SizedboxSpaccing.height012(context),
          Text(
            'Dinmajur will accept orders within a short time.',
            style: AppTextStyles.textSize16(context, weight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Payment Method Section ────────────────────────────────────────────────────
  Widget _buildPaymentMethodSection() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<TrackOrderViewModel>(
      builder: (context, vm, _) => Column(
        children: [
          SectionHeader(title: 'Payment Method', titleWidth: screenWidth * 0.6, showSeeAll: false),
          SizedboxSpaccing.height02(context),
          PaymentMethodWidget(selectedPaymentMethod: vm.selectedPaymentMethod, paymentMethods: vm.paymentMethods, onPaymentMethodChanged: vm.setPaymentMethod),
        ],
      ),
    );
  }

  // ── Dual Terms Checkbox ───────────────────────────────────────────────────────
  Widget _buildDualTermsCheckbox() {
    return Consumer<TrackOrderViewModel>(
      builder: (context, vm, _) => DualTermsCheckbox(
        isTermsAccepted: vm.isTermsAccepted,
        isReviewAccepted: vm.isReviewAccepted,
        onTermsChanged: vm.setTermsAccepted,
        onReviewChanged: vm.setReviewAccepted,
        context: context,
        onTermsTap: () => Navigator.pushNamed(context, RoutesName.termsAndCondition),
        onPrivacyTap: () => Navigator.pushNamed(context, RoutesName.privacyPolicy),
        onRefundTap: () => Navigator.pushNamed(context, RoutesName.refundPolicyScreen),
        getButtonColor: (ctx) => AppColors.button(ctx),
        getBorderColor: (ctx) => AppColors.border(ctx),
        getWhiteColor: (ctx) => AppColors.whiteColor,
        getTextStyle: (ctx, {weight}) => AppTextStyles.textSize14(ctx, weight: weight ?? FontWeight.w400),
      ),
    );
  }

  // ── Total Section ─────────────────────────────────────────────────────────────
  Widget _buildTotalSection(Order order) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double subtotal = _vm.calculateSubtotal(order);
    final double serviceFee = order.customerPlatformFee?.toDouble() ?? 0;
    final double deliveryFee = order.deliveryCharge?.toDouble() ?? 0;
    final double total = _vm.calculateTotal(order);
    final int foundItems = _vm.getFoundItemsCount(order.items);

    return Column(
      children: [
        SectionHeader(title: 'Payment Summary', titleWidth: screenWidth * 0.6, showSeeAll: false),
        SizedboxSpaccing.height02(context),
        Container(
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          padding: EdgeInsets.all(screenHeight * 0.02),
          child: Column(
            children: [
              _summaryRow('Total Order:', '$foundItems items'),
              SizedboxSpaccing.height015(context),
              _summaryRow('Subtotal:', '৳${subtotal.toStringAsFixed(0)}'),
              SizedboxSpaccing.height015(context),
              _summaryRow('Delivery Fee:', '৳${deliveryFee.toStringAsFixed(0)}'),
              SizedboxSpaccing.height015(context),
              _summaryRow('Service Fee:', '৳${serviceFee.toStringAsFixed(0)}'),
              SizedboxSpaccing.height015(context),
              Divider(height: 1, color: AppColors.border(context)),
              SizedboxSpaccing.height015(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount:', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                  Text('৳${total.toStringAsFixed(0)}', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Pay Now Button ────────────────────────────────────────────────────────────
  Widget _buildPayNowButton(Order order, Payment payment, Delivery delivery) {
    return GestureDetector(
      onTap: () => _vm.handlePayNow(context: context, order: order, payment: payment, delivery: delivery),
      child: Container(
        height: 48,
        width: double.infinity,
        decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            'Pay Now',
            style: AppTextStyles.textSize16(context, weight: FontWeight.w600, color: AppColors.whiteColor),
          ),
        ),
      ),
    );
  }

  // ── Payment Status Banner ─────────────────────────────────────────────────────
  Widget _buildPaymentStatusBanner(Payment? payment) {
    if (payment == null) return const SizedBox.shrink();

    final String type = payment.paymentType ?? '';
    if (type != 'ONLINE' && type != 'CASH_ON_DELIVERY') {
      return const SizedBox.shrink();
    }

    final bool isOnline = type == 'ONLINE';

    final Color bannerColor = isOnline ? Colors.blue.withOpacity(0.05) : Colors.green.withOpacity(0.05);
    final Color borderColor = isOnline ? Colors.blue : Colors.green;
    final String message = isOnline
        ? 'Your online payment has been successfully completed.'
        : 'You have selected the payment method Hand Cash.\nPlease give payment to freelancer via\nCash On Deliver.';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
          decoration: BoxDecoration(
            color: bannerColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.textSize16(context, weight: FontWeight.w500),
          ),
        ),
        SizedboxSpaccing.height02(context),
      ],
    );
  }

  // ── Shared Helpers ────────────────────────────────────────────────────────────
  Widget _dot() {
    return SizedBox(
      height: 12,
      width: 20,
      child: Center(
        child: Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(color: AppColors.button(context), shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.textSize14(context, weight: FontWeight.w400, color: AppColors.subtitle(context)),
        ),
        Text(value, style: AppTextStyles.textSize14(context, weight: FontWeight.w400)),
      ],
    );
  }

  // ── Phone Actions ─────────────────────────────────────────────────────────────
  Future<void> _makePhoneCall(String phoneNumber) async {
    final String cleanNumber = _vm.cleanPhoneNumber(phoneNumber);
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        Utils.flushBarErrorMessage('Could not launch phone dialer', context);
      }
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    String cleanNumber = _vm.cleanPhoneNumber(phoneNumber);
    if (cleanNumber.startsWith('0')) cleanNumber = cleanNumber.substring(1);
    final Uri whatsappUri = Uri.parse('https://wa.me/+880$cleanNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        Utils.flushBarErrorMessage('Could not open WhatsApp', context);
      }
    }
  }
}
