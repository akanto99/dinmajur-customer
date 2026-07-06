import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/get_all_service_models.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/check_coverage_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> navigateToService(
  BuildContext context,
  Datum service, {
  required String customerName,
  required String customerPhone,
  required String customerAddress,
  required Map<String, dynamic>? customerLocation,
}) async {
  final checkCoverageViewModel = Provider.of<CheckCoverageViewModel>(context, listen: false);
  await checkCoverageViewModel.fetchCheckCoverageDataApi();

  if (!context.mounted) return;

  final isInside = checkCoverageViewModel.checkCoverageData.data?.data?.insideServiceArea ?? false;

  if (!isInside) {
    Utils.flushBarErrorMessage("Service not available in your area", context);
    return;
  }

  if (service.isPartner == true) {
    Navigator.pushNamed(
      context,
      RoutesName.getAllNearbyServiceStoresScreen,
      arguments: {
        'serviceId': service.id,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerAddress': customerAddress,
        'serviceName': service.name,
        'description': service.description,
        'customerLocation': customerLocation,
      },
    );
    return;
  }
  final slug = service.slug ?? '';
  switch (slug) {
    case 'house-keeper':
      Navigator.pushNamed(
        context,
        RoutesName.bookNowPremiumHouseKeeper,
        arguments: {
          'customerName': customerName,
          'customerPhone': customerPhone,
          'customerAddress': customerAddress,
          'serviceName': service.name,
          'description': service.description,
          'customerLocation': customerLocation,
        },
      );
      break;
    case 'beauty-parlour':
      Navigator.pushNamed(
        context,
        RoutesName.bookNowHomeBeautySalonScreen,
        arguments: {
          'customerName': customerName,
          'customerPhone': customerPhone,
          'customerAddress': customerAddress,
          'serviceName': service.name,
          'description': service.description,
          'customerLocation': customerLocation,
        },
      );
      break;
    case 'family-event-cooking':
      Navigator.pushNamed(
        context,
        RoutesName.familyEventCookingScreen,
        arguments: {
          'customerName': customerName,
          'customerPhone': customerPhone,
          'customerAddress': customerAddress,
          'serviceName': service.name,
          'description': service.description,
          'customerLocation': customerLocation,
        },
      );
      break;

    default:
      Navigator.pushNamed(
        context,
        RoutesName.servicesViewScreen,
        arguments: {
          'serviceId': service.id,
          'customerName': customerName,
          'customerPhone': customerPhone,
          'customerAddress': customerAddress,
          'serviceName': service.name,
          'description': service.description,
          'isFromHome': true,
          'customerLocation': customerLocation,
        },
      );
      break;
  }
}
