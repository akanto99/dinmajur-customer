// File: lib/model/home_models/dropdown_categories_selection_models/family_event_cooking_model/event_cooking_receipt_adapter.dart
import 'package:dinmajur_customer/configs/res/components/pdf_reciept_generator_auto_open_download/event_cooking_pdf_generator/event_cooking_generator.dart';
import '../../../../../model/home_models/dropdown_categories_selection_models/family_event_cooking_model/getdetails_family_event_booking_model.dart';

/// Adapter extension to convert Event Cooking booking data to Universal Receipt format
extension EventCookingReceiptAdapter on Data {

  /// Convert Event Cooking booking data to UniversalReceiptData for PDF generation
  UniversalReceiptData toUniversalReceiptData() {
    // Determine booking type (REGULAR or MANUAL)
    final String bookingType;
    if (eventCookingCategory is EventCookingCategory) {
      bookingType = (eventCookingCategory as EventCookingCategory).type ?? 'REGULAR';
    } else {
      final bool hasManualItems = items?.any((item) => item.isManual) ?? false;
      bookingType = hasManualItems ? 'MANUAL' : 'REGULAR';
    }

    // Extract guest range from first item's price details
    String? guestRange;
    if (items != null && items!.isNotEmpty) {
      final firstItem = items!.first;

      if (firstItem.isManual && firstItem.items != null && firstItem.items!.isNotEmpty) {
        // For MANUAL, get from first item wrapper
        guestRange = firstItem.items!.first.price?.guestRange?.label;
      } else {
        // For REGULAR, get from item's price
        guestRange = firstItem.price?.guestRange?.label;
      }
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
      time: null,
      slot: slot,
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

    List<UniversalServiceItem> services = [];

    for (var bookingItem in items!) {
      if (bookingItem.isManual) {
        // MANUAL booking - one service per package with multiple items
        final packageName = bookingItem.package?.name ?? 'Unknown Package';
        List<UniversalSubItem> subItems = [];
        num totalPrice = 0;

        if (bookingItem.items != null && bookingItem.items!.isNotEmpty) {
          for (var itemWrapper in bookingItem.items!) {
            final itemName = itemWrapper.item?.name ?? 'Item';
            final itemPrice = itemWrapper.price?.salePrice ?? 0;

            subItems.add(UniversalSubItem(
              name: itemName,
              price: itemPrice,
            ));

            totalPrice += itemPrice;
          }
        }

        services.add(UniversalServiceItem(
          serviceName: packageName,
          items: subItems,
          quantity: 1,
          totalPrice: totalPrice,
        ));
      } else {
        // REGULAR booking - one service per package
        final serviceName = categoryName ?? '';
        final packageName = bookingItem.package?.name ?? 'Package';
        final itemPrice = bookingItem.price?.salePrice ?? 0;

        services.add(UniversalServiceItem(
          serviceName: serviceName,
          items: [
            UniversalSubItem(
              name: packageName,
              price: itemPrice,
            ),
          ],
          quantity: 1,
          totalPrice: itemPrice,
        ));
      }
    }

    return services;
  }
}