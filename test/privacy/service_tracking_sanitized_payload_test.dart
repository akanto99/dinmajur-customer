import 'package:dinmajur_customer/model/home_models/all_service_models/getservice_confirmationdetails_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// **The installed app must survive the backend withholding contact details.**
///
/// `GET /bookings/tracking/:id` used to hand the customer's phone, email, full
/// address, notes and delivery location to anyone holding a tracking id. It now
/// answers an unauthenticated caller with those fields removed, and only the
/// owning customer or an admin receives them.
///
/// Every build already on a phone parses that response. This pins that the
/// sanitised shape still parses, that the missing fields read as null rather
/// than throwing, and that the screens' fallbacks produce something sensible -
/// so the migration cannot brick a confirmation screen in the field.
///
/// The payload below mirrors what the backend now returns to a guest: the same
/// keys, minus the sensitive ones.
void main() {
  Map<String, dynamic> sanitisedResponse() => {
        'success': true,
        'message': 'Booking fetched successfully',
        'data': {
          '_id': '6aaadfb4b79ef9030e8b3e82',
          'freelancerId': '6aaadfb4b79ef9030e8b3e83',
          'trackingId': 'BK-TRACK-1',
          'fullName': 'Tracking Owner',
          // phone, email, fullAddress, notes and deliveryLocation are absent
          'date': '2026-10-02T09:30:00.000Z',
          'time': '09:30',
          'timeSlotSnapshot': {
            '_id': '6aaadfb4b79ef9030e8b3e84',
            'timeLabel': '9:30 AM - 11:30 AM',
          },
          'subTotal': 1000,
          'vat': 50,
          'fare': 20,
          'total': 1050,
          'grandTotal': 1070,
          'status': 'PENDING',
          'serviceSnapshot': {
            '_id': '6aaadfb4b79ef9030e8b3e85',
            'name': 'Deep Clean',
          },
          'paymentType': 'cash on delivery',
          'paymentStatus': null,
          'discountValue': 0,
          'bookingItems': [
            {
              '_id': '6aaadfb4b79ef9030e8b3e86',
              'task': {
                'name': 'Kitchen',
                'price': {'basePrice': 500, 'salePrice': 450},
              },
              'quantity': 2,
              'status': 'PENDING',
            }
          ],
          'extraItemsTrackingId': null,
          'extraItemsPaymentStatus': null,
          'extraItemsStatus': null,
          'totalExtraAmount': 0,
          'extraItems': [],
        },
      };

  group('the sanitised tracking payload', () {
    test('parses without throwing', () {
      expect(
        () => ServiceConfirmationDetailsModel.fromJson(sanitisedResponse()),
        returnsNormally,
      );
    });

    test('reads the withheld fields as null rather than failing', () {
      final data =
          ServiceConfirmationDetailsModel.fromJson(sanitisedResponse()).data!;
      expect(data.phone, isNull);
      expect(data.email, isNull);
      expect(data.fullAddress, isNull);
      expect(data.notes, isNull);
    });

    test('still carries everything the confirmation screen shows', () {
      final data =
          ServiceConfirmationDetailsModel.fromJson(sanitisedResponse()).data!;
      expect(data.trackingId, 'BK-TRACK-1');
      expect(data.status, 'PENDING');
      expect(data.serviceSnapshot?.name, 'Deep Clean');
      expect(data.time, '09:30');
      expect(data.timeSlotSnapshot?.timeLabel, '9:30 AM - 11:30 AM');
      expect(data.date, DateTime.parse('2026-10-02T09:30:00.000Z'));
      expect(data.subTotal, 1000);
      expect(data.vat, 50);
      expect(data.fare, 20);
      expect(data.total, 1050);
      expect(data.grandTotal, 1070);
      expect(data.paymentType, 'cash on delivery');
      expect(data.bookingItems, hasLength(1));
      expect(data.bookingItems!.first.task?.name, 'Kitchen');
      expect(data.bookingItems!.first.task?.price?.salePrice, 450);
      expect(data.bookingItems!.first.quantity, 2);
      expect(data.extraItems, isEmpty);
    });

    test("the screens' fallbacks turn the missing fields into safe text", () {
      // service_confirmed_screen.dart and service_failed_screen.dart read these
      // as `?? ''` and `?? 'N/A'`, and pdf_generator.dart guards each one with a
      // null check before using it. This reproduces those expressions, so the
      // test fails if the model ever starts throwing instead of yielding null.
      final data =
          ServiceConfirmationDetailsModel.fromJson(sanitisedResponse()).data!;
      expect(data.phone ?? '', '');
      expect(data.email ?? '', '');
      expect(data.fullAddress ?? '', '');
      expect(data.fullAddress ?? 'N/A', 'N/A');
      expect(data.fullName ?? '', 'Tracking Owner');
      expect(data.phone != null, isFalse); // the PDF row is simply omitted
    });
  });

  group('the full payload an owner receives still parses', () {
    test('contact details come through when the backend sends them', () {
      final response = sanitisedResponse();
      (response['data'] as Map<String, dynamic>).addAll({
        'phone': '8801711111111',
        'email': 'owner@example.test',
        'fullAddress': 'House 12, Road 4, Banani, Dhaka',
        'notes': 'Gate code at the door',
      });

      final data = ServiceConfirmationDetailsModel.fromJson(response).data!;
      expect(data.phone, '8801711111111');
      expect(data.email, 'owner@example.test');
      expect(data.fullAddress, 'House 12, Road 4, Banani, Dhaka');
      expect(data.notes, 'Gate code at the door');
    });
  });
}
