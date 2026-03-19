// import 'package:dinmajur_customer/configs/res/color.dart';
// import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
// import 'package:dinmajur_customer/configs/res/text_styles.dart';
// import 'package:dinmajur_customer/data/response/status.dart';
// import 'package:dinmajur_customer/model/home_models/all_service_models/get_all_service_models.dart';
// import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/get_all_service_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:provider/provider.dart';
//
// class AllServicesGridWidget extends StatelessWidget {
//   final Function(Datum)? onServiceTap;
//   final String? selectedServiceId;
//
//   const AllServicesGridWidget({Key? key, this.onServiceTap, this.selectedServiceId}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Consumer<GetAllServiceViewModel>(
//       builder: (context, viewModel, _) {
//         switch (viewModel.getAllServicesData.status) {
//           case Status.LOADING:
//             return Container(
//               width: screenWidth * 0.9,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "All Services",
//                     style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
//                   ),
//                   SizedboxSpaccing.height012(context),
//                   Row(
//                     children: List.generate(
//                       3,
//                       (index) => Expanded(
//                         child: Padding(
//                           padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
//                           child: _buildShimmerCard(context),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//
//           case Status.ERROR:
//             return SizedBox.shrink();
//
//           case Status.COMPLETED:
//             final services = viewModel.getAllServicesData.data?.data ?? [];
//             if (services.isEmpty) return SizedBox.shrink();
//
//             return Container(
//               width: screenWidth * 0.9,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "All Services",
//                     style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
//                   ),
//                   SizedboxSpaccing.height012(context),
//                   _buildServicesGrid(context, services),
//                 ],
//               ),
//             );
//
//           default:
//             return SizedBox.shrink();
//         }
//       },
//     );
//   }
//
//   Widget _buildServicesGrid(BuildContext context, List<Datum> services) {
//     List<Widget> rows = [];
//
//     for (int i = 0; i < services.length; i += 3) {
//       final rowItems = services.skip(i).take(3).toList();
//
//       rows.add(
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             // Fill actual items
//             ...List.generate(rowItems.length, (index) {
//               return Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
//                   child: _buildServiceCard(context, rowItems[index]),
//                 ),
//               );
//             }),
//             // Fill empty slots to keep 3-column layout
//             ...List.generate(3 - rowItems.length, (_) {
//               return Expanded(child: SizedBox());
//             }),
//           ],
//         ),
//       );
//
//       if (i + 3 < services.length) {
//         rows.add(SizedBox(height: 24));
//       }
//     }
//
//     return Column(children: rows);
//   }
//   Widget _buildServiceCard(BuildContext context, Datum service) {
//     final isSelected = selectedServiceId == service.id;
//
//     return GestureDetector(
//       onTap: onServiceTap != null ? () => onServiceTap!(service) : null,
//       child: Column(
//         children: [
//           Container(
//             height: 100,
//             width: 100,
//             decoration: BoxDecoration(
//               color: AppColors.containerBackground(context),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 width: 1,
//                 color: isSelected
//                     ? AppColors.textPrimary(context)
//                     : AppColors.border(context),
//               ),
//             ),
//             child: Center(
//               child: Container(
//                 height: 80,
//                 width: 80,
//                 child: service.image?.url != null
//                     ? CachedNetworkImage(
//                   imageUrl: service.image!.url!,
//                   fit: BoxFit.contain,
//                   errorWidget: (context, url, error) => Icon(
//                     Icons.design_services_outlined,
//                     color: AppColors.subtitle(context),
//                     size: 32,
//                   ),
//                 )
//                     : Icon(
//                   Icons.design_services_outlined,
//                   color: AppColors.subtitle(context),
//                   size: 32,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             service.name ?? '',
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: AppTextStyles.textSize12(
//               context,
//               weight: FontWeight.w500,
//               color: AppColors.textPrimary(context),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildShimmerCard(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           height: 100,
//           width: 100,
//           decoration: BoxDecoration(color: AppColors.border(context), borderRadius: BorderRadius.circular(12)),
//         ),
//         SizedBox(height: 8),
//         Container(
//           height: 12,
//           width: 60,
//           decoration: BoxDecoration(color: AppColors.border(context), borderRadius: BorderRadius.circular(4)),
//         ),
//       ],
//     );
//   }
// }
import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/routes/routes_name.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/get_all_service_models.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/get_all_service_view_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/dropdown_categories_selection_view_models/premium_house_keeper_view_model/check_coverage_view_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class AllServicesGridWidget extends StatefulWidget {
  final String? selectedServiceId;

  const AllServicesGridWidget({Key? key, this.selectedServiceId}) : super(key: key);

  @override
  State<AllServicesGridWidget> createState() => _AllServicesGridWidgetState();
}

class _AllServicesGridWidgetState extends State<AllServicesGridWidget> {
  String? _loadingServiceId; // tracks which card is showing loading

  Future<void> _handleServiceTap(Datum service) async {
    if (_loadingServiceId != null) return;

    setState(() {
      _loadingServiceId = service.id;
    });

    try {
      final checkCoverageViewModel = Provider.of<CheckCoverageViewModel>(context, listen: false);
      await checkCoverageViewModel.fetchCheckCoverageDataApi();

      if (!mounted) return;

      final isInside = checkCoverageViewModel.checkCoverageData.data?.data?.insideServiceArea ?? false;

      if (!isInside) {
        // Optional: show a message if not in coverage
        Utils.flushBarErrorMessage("Service not available in your area", context);
        return;
      }

      // Navigator.pushNamed(
      //   context,
      //   RoutesName.servicesViewScreen,
      //   arguments: {'serviceId': service.id},
      // );
    } catch (e) {
      debugPrint('Coverage check failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loadingServiceId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<GetAllServiceViewModel>(
      builder: (context, viewModel, _) {
        switch (viewModel.getAllServicesData.status) {
          case Status.LOADING:
            return Container(
              width: screenWidth * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "All Services",
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
                  ),
                  SizedboxSpaccing.height012(context),
                  Row(
                    children: List.generate(
                      3,
                      (index) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
                          child: _buildShimmerCard(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );

          case Status.ERROR:
            return SizedBox.shrink();

          case Status.COMPLETED:
            final services = viewModel.getAllServicesData.data?.data ?? [];
            if (services.isEmpty) return SizedBox.shrink();

            return Container(
              width: screenWidth * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "All Services",
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
                  ),
                  SizedboxSpaccing.height012(context),
                  _buildServicesGrid(context, services),
                  SizedboxSpaccing.height025(context),
                ],
              ),
            );

          default:
            return SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildServicesGrid(BuildContext context, List<Datum> services) {
    List<Widget> rows = [];

    for (int i = 0; i < services.length; i += 3) {
      final rowItems = services.skip(i).take(3).toList();

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ...List.generate(rowItems.length, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
                  child: _buildServiceCard(context, rowItems[index]),
                ),
              );
            }),
            ...List.generate(3 - rowItems.length, (_) {
              return Expanded(child: SizedBox());
            }),
          ],
        ),
      );

      if (i + 3 < services.length) {
        rows.add(SizedBox(height: 24));
      }
    }

    return Column(children: rows);
  }

  Widget _buildServiceCard(BuildContext context, Datum service) {
    final isSelected = widget.selectedServiceId == service.id;
    final isLoading = _loadingServiceId == service.id;

    return GestureDetector(
      onTap: () => _handleServiceTap(service),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Main card container
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: AppColors.containerBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    width: isLoading ? 2 : 1,
                    color: isLoading
                        ? AppColors.textPrimary(context)
                        : isSelected
                        ? AppColors.textPrimary(context)
                        : AppColors.border(context),
                  ),
                ),
                child: Center(
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    opacity: isLoading ? 0.3 : 1.0,
                    child: Container(
                      height: 80,
                      width: 80,
                      child: service.image?.url != null
                          ? CachedNetworkImage(
                              imageUrl: service.image!.url!,
                              fit: BoxFit.contain,
                              errorWidget: (context, url, error) => Icon(Icons.design_services_outlined, color: AppColors.subtitle(context), size: 32),
                            )
                          : Icon(Icons.design_services_outlined, color: AppColors.subtitle(context), size: 32),
                    ),
                  ),
                ),
              ),

              // Loading overlay on the card
              if (isLoading)
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(color: AppColors.containerBackground(context).withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.textPrimary(context))),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            service.name ?? '',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textSize12(context, weight: isLoading ? FontWeight.w600 : FontWeight.w500, color: isLoading ? AppColors.textPrimary(context) : AppColors.textPrimary(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(color: AppColors.border(context), borderRadius: BorderRadius.circular(12)),
        ),
        SizedBox(height: 8),
        Container(
          height: 12,
          width: 60,
          decoration: BoxDecoration(color: AppColors.border(context), borderRadius: BorderRadius.circular(4)),
        ),
      ],
    );
  }
}
