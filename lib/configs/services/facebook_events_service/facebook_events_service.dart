import 'package:facebook_app_events/facebook_app_events.dart';

class FacebookEventsService {
  FacebookEventsService._internal();
  static final FacebookEventsService _instance = FacebookEventsService._internal();
  factory FacebookEventsService() => _instance;

  final FacebookAppEvents _events = FacebookAppEvents();

  Future<void> init() async {
    await _events.setGraphApiVersion('v24.0');
    await _events.activateApp();
  }

  // The plugin has no dedicated logContact/logSearched wrappers, so these
  // use logEvent directly with Meta's standard event/parameter names:
  // https://developers.facebook.com/docs/app-events/best-practices#standard-events

  Future<void> logContact() => _events.logEvent(name: 'Contact');

  Future<void> logSearched({String? searchString, String? contentType, String? contentId}) {
    return _events.logEvent(
      name: 'fb_mobile_search',
      parameters: {
        if (searchString != null) 'fb_search_string': searchString,
        if (contentType != null) 'fb_content_type': contentType,
        if (contentId != null) 'fb_content_id': contentId,
      },
    );
  }

  Future<void> logCompletedRegistration({String? registrationMethod}) {
    return _events.logCompletedRegistration(registrationMethod: registrationMethod);
  }

  Future<void> logViewContent({String? id, String? type}) {
    return _events.logViewContent(id: id, type: type);
  }

  /// Not wired up to any screen yet — this app has no paid-subscription
  /// feature. Kept available for when one exists.
  Future<void> logSubscribe({required String orderId, double? price, String? currency}) {
    return _events.logSubscribe(orderId: orderId, price: price, currency: currency);
  }

  Future<void> logInitiatedCheckout({String? contentId, String? contentType, String? currency, double? totalPrice}) {
    return _events.logInitiatedCheckout(
      contentId: contentId,
      contentType: contentType,
      currency: currency,
      totalPrice: totalPrice,
    );
  }
}
