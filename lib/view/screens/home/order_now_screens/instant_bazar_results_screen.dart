import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/responsive/responsive_ui.dart';
import 'package:dinmajur_customer/view/screens/home/dorpdown_categories_selections_and_views/grocery/grocery_sction_widget.dart';
import 'package:dinmajur_customer/view/screens/home/helper_widgets/dynamic_nearestheader_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class InstantBazarResultsScreen extends StatelessWidget {
  final List<dynamic> stores;
  final Map<String, String> storeTypes;
  final Position? currentPosition;
  final String? currentAddress;
  final VoidCallback? onSeeAllTap;

  const InstantBazarResultsScreen({
    Key? key,
    required this.stores,
    required this.storeTypes,
    this.currentPosition,
    this.currentAddress,
    this.onSeeAllTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final body = _body(context);
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: ResPonsiveUi(mobile: body, desktop: body, tablet: body),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: AppBarHeader('Instant Bazar')),


        // ── Scrollable Content ──
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedboxSpaccing.height025(context),
                DynamicNearestHeader(
                  selectedStoreType: 'Retail',
                  storeCount: stores.length,
                  screenWidth: screenWidth,
                  isInsideServiceArea: null,
                  onSeeAllTap: onSeeAllTap ?? () => Navigator.pop(context),
                ),
                SizedboxSpaccing.height025(context),
                GroceryStoresSection(
                  isLoading: false,
                  stores: stores,
                  storeTypes: storeTypes,
                  selectedStoreType: 'Retail',
                  currentPosition: currentPosition,
                  currentAddress: currentAddress,
                ),
                SizedboxSpaccing.height02(context),
              ],
            ),
          ),
        ),
      ],
    );
  }
}