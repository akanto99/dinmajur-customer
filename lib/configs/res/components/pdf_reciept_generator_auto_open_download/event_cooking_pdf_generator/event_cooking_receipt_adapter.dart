// File: lib/model/home_models/dropdown_categories_selection_models/family_event_cooking_model/event_cooking_receipt_adapter.dart
import 'package:dinmajur_customer/configs/res/components/pdf_reciept_generator_auto_open_download/event_cooking_pdf_generator/event_cooking_generator.dart';

import '../../../../../model/home_models/dropdown_categories_selection_models/family_event_cooking_model/getdetails_family_event_booking_model.dart';


/// Adapter extension to convert Event Cooking booking data to Universal Receipt format
extension EventCookingReceiptAdapter on Data {

  /// Convert Event Cooking booking data to UniversalReceiptData for PDF generation
  UniversalReceiptData toUniversalReceiptData() {
    // Determine booking type (REGULAR or MANUAL)
    final bool hasManualItems = items?.any((item) => item.isManual) ?? false;
    final String bookingType = hasManualItems ? 'MANUAL' : 'REGULAR';

    // Extract guest range from first item's price details
    String? guestRange;
    if (items != null && items!.isNotEmpty) {
      final firstItem = items!.first;
      guestRange = firstItem.priceDetails?.guestRange;
    }

    // Convert booking items to universal service format
    final services = _convertToUniversalServices();

    return UniversalReceiptData(
      trackingId: trackingId ?? 'N/A',
      customerName: fullName,
      phone: phone,
      email: (email != null && email!.isNotEmpty) ? email : null,
      address: fullAddress,
      notes: null,
      status: status,
      date: date,
      time: null, // Update this if you have slot/time info in your model
      bookingType: bookingType,
      guestRange: guestRange,
      paymentMethod: paymentType,
      services: services,
      paymentSummary: UniversalPaymentSummary(
        subTotal: subTotal ?? 0,
        vat: vat ?? 0,
        transportationFee: transportFee ?? 0,
        discount: discountValue ?? 0,
        total: total ?? 0,
        grandTotal: grandTotal ?? 0,
      ),
      footerMessage: 'Thank you for choosing our event cooking service!',
      contactNumber: '01929600600',
    );
  }

  /// Convert items to universal service format with smart grouping
  List<UniversalServiceItem> _convertToUniversalServices() {
    if (items == null || items!.isEmpty) {
      return [];
    }

    // Group items for better presentation
    Map<String, List<EventCookingItem>> groupedItems = {};

    for (var item in items!) {
      String groupKey;

      if (item.isManual) {
        // MANUAL: Group by package name
        groupKey = item.package?.name ?? 'Unknown Package';
      } else {
        // REGULAR: Group by category name (if available) or package name
        groupKey = eventCookingCategory ?? item.package?.name ?? 'Service';
      }

      if (!groupedItems.containsKey(groupKey)) {
        groupedItems[groupKey] = [];
      }
      groupedItems[groupKey]!.add(item);
    }

    // Convert grouped items to UniversalServiceItem list
    List<UniversalServiceItem> services = [];

    groupedItems.forEach((serviceName, itemsList) {
      List<UniversalSubItem> subItems = [];
      num totalPrice = 0;

      for (var item in itemsList) {
        String itemName;
        num itemPrice = 0;

        if (item.isManual) {
          // MANUAL: Item name from nested structure
          itemName = item.item?.item?.name ?? 'Item';
          itemPrice = item.priceDetails?.salePrice ?? 0;
        } else {
          // REGULAR: Package name
          itemName = item.package?.name ?? 'Package';
          itemPrice = item.priceDetails?.salePrice ?? 0;
        }

        subItems.add(UniversalSubItem(
          name: itemName,
          price: itemPrice,
        ));

        totalPrice += itemPrice;
      }

      services.add(UniversalServiceItem(
        serviceName: serviceName,
        items: subItems,
        quantity: 1, // Event cooking doesn't use quantity
        totalPrice: totalPrice,
      ));
    });

    return services;
  }
}