import 'package:dinmajur_customer/configs/services/ssl_payment_service/ssl_payment.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/services_view_getallcategories_model.dart';
import 'package:flutter/material.dart';

class CheckoutAllServicesViewModel extends ChangeNotifier {
  // ── display value shown in UI e.g. "09:00"
  String? _selectedServiceTime;
  // ── the _id from the slot API — this is ALL we send to the booking API
  String? _selectedTimeSlotId;
  String? _selectedPaymentMethod;
  DateTime? _selectedDate;
  bool _isProcessing = false;

  String? get selectedServiceTime => _selectedServiceTime;
  String? get selectedTimeSlotId => _selectedTimeSlotId;
  String? get selectedPaymentMethod => _selectedPaymentMethod;
  DateTime? get selectedDate => _selectedDate;
  bool get isProcessing => _isProcessing;

  final SSLCommerzPaymentService _paymentService = SSLCommerzPaymentService();

  final List<Map<String, dynamic>> paymentMethods = [
    {'method': 'online', 'title': 'Online Payment', 'icon': 'wallet', 'color': 0xFFEE4237},
    {'method': 'cash', 'title': 'Hand Cash', 'icon': 'sackDollar', 'color': 0xFF45A986},
  ];

  /// Call this when the user taps a slot chip.
  /// [time] is the display label ("09:00"), [slotId] is the API _id.
  void setServiceTime(String time, String slotId) {
    _selectedServiceTime = time;
    _selectedTimeSlotId = slotId;
    notifyListeners();
  }

  /// Call this when the user picks a new date.
  /// Clears the previously selected slot so they must pick again.
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _selectedServiceTime = null;
    _selectedTimeSlotId = null;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void setProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }

  // ── Totals ───────────────────────────────────────────────────────────────

  double calculateTotal({
    required Map<String, int> serviceQuantities,
    required List<Category> categories,
  }) {
    double total = 0;
    for (final cat in categories) {
      for (final task in (cat.tasks ?? [])) {
        final qty = serviceQuantities[task.id ?? ''] ?? 0;
        if (qty > 0) {
          final price = task.price?.salePrice?.toDouble() ?? task.price?.basePrice?.toDouble() ?? 0;
          total += price * qty;
        }
      }
    }
    return total;
  }

  double calculateSaved({
    required Map<String, int> serviceQuantities,
    required List<Category> categories,
  }) {
    double saved = 0;
    for (final cat in categories) {
      for (final task in (cat.tasks ?? [])) {
        final qty = serviceQuantities[task.id ?? ''] ?? 0;
        if (qty > 0) {
          final base = task.price?.basePrice?.toDouble() ?? 0;
          final sale = task.price?.salePrice?.toDouble() ?? base;
          if (base > sale) saved += (base - sale) * qty;
        }
      }
    }
    return saved;
  }

  int getTotalItems(Map<String, int> serviceQuantities) =>
      serviceQuantities.entries.where((e) => e.value > 0).length;

  // ── Validation ───────────────────────────────────────────────────────────

  String? validateCartForm({
    required DateTime? selectedDate,
    required String? serviceTime,
  }) {
    if (selectedDate == null) return "Please select a date";
    if (serviceTime == null || serviceTime.isEmpty) return "Please select a time slot";
    return null;
  }

  String? validateCheckoutDetails({
    required String fullName,
    required String phone,
    required String address,
    required String? paymentMethod,
  }) {
    if (fullName.trim().isEmpty) return "Please enter your full name";
    if (phone.trim().isEmpty) return "Please enter your phone number";
    if (address.trim().isEmpty) return "Please enter your address";
    if (paymentMethod == null || paymentMethod.isEmpty) return "Please select a payment method";
    return null;
  }

  String getPaymentMethodData(String? method) {
    switch (method) {
      case 'online': return "ONLINE";
      case 'cash': return "CASH_ON_DELIVERY";
      default: return "OTHERS";
    }
  }

  // ── Payload ──────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> prepareTasksData({
    required Map<String, int> serviceQuantities,
    required List<Category> categories,
  }) {
    final List<Map<String, dynamic>> tasks = [];
    for (final cat in categories) {
      for (final task in (cat.tasks ?? [])) {
        final qty = serviceQuantities[task.id ?? ''] ?? 0;
        if (qty > 0) tasks.add({'taskId': task.id, 'quantity': qty});
      }
    }
    return tasks;
  }

  /// Only [timeSlotId] (the `_id` from the slot response) is sent to the
  /// booking API — no raw date/time strings are needed.
  Map<String, dynamic> prepareBookingData({
    String? retailerId,
    required String serviceId,
    required String customerId,
    required String? paymentMethod,
    required String address,
    required String fullName,
    required String phone,
    required String email,
    required String? specialRequest,
    required String selectedDate,
    required String timeSlotId,
     required String platform,
    Map<String, dynamic>? customerLocation,

    required List<Map<String, dynamic>> tasks,


  }) {
    return {
      if (retailerId != null && retailerId.isNotEmpty)
        'retailerId': retailerId,
      'serviceId': serviceId,
      'customerId': customerId,
      'paymentType': getPaymentMethodData(paymentMethod),
      'fullAddress': address.trim(),
      'fullName': fullName.trim(),
      'phone': phone.trim(),
      'email':email.toString(),
      'notes': (specialRequest?.trim().isEmpty ?? true) ? null : specialRequest?.trim(),

      "date":selectedDate.toString() ,
      'timeSlotId': timeSlotId,
      "platform": platform.toString(),

      if (customerLocation != null) 'location': customerLocation,


      'tasks': tasks,

    };
  }

  // ── Payment ──────────────────────────────────────────────────────────────

  Future<SSLPaymentResult> initiatePayment({
    required String trackingId,
    required double totalAmount,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerAddress,
  }) async {
    try {
      return await _paymentService.initiatePayment(
        trackingId: trackingId,
        totalAmount: totalAmount,
        productCategory: "Service",
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        customerAddress: customerAddress,
      );
    } catch (e) {
      return SSLPaymentResult(
        success: false,
        status: 'ERROR',
        errorMessage: 'Failed to initiate payment: ${e.toString()}',
      );
    }
  }

  void reset() {
    _selectedServiceTime = null;
    _selectedTimeSlotId = null;
    _selectedPaymentMethod = null;
    _selectedDate = null;
    _isProcessing = false;
    notifyListeners();
  }
}