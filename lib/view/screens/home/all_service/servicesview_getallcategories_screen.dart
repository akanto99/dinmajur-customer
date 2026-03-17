import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/home_models/all_service_models/services_view_getallcategories_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/all_service_view_models/services_view_getallcategories_view_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class ServicesViewScreen extends StatefulWidget {
  final String serviceId;
  const ServicesViewScreen({Key? key, required this.serviceId}) : super(key: key);

  @override
  State<ServicesViewScreen> createState() => _ServicesViewScreenState();
}

class _ServicesViewScreenState extends State<ServicesViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServicesViewGetAllCategoriesViewModel>(context, listen: false)
          .fetchServicesViewGetAllCategoriesGetApi(widget.serviceId);
    });
        }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.containerBackground(context),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary(context), size: 20),
        ),
        title: Text('Services', style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
      ),
      body: Consumer<ServicesViewGetAllCategoriesViewModel>(
        builder: (context, viewModel, _) {
          switch (viewModel.servicesViewGetAllCategoryData.status) {
            case Status.LOADING:
              return Center(child: CircularProgressIndicator(color: AppColors.textPrimary(context), strokeWidth: 2));

            case Status.ERROR:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: AppColors.subtitle(context), size: 48),
                    SizedBox(height: 12),
                    Text(
                      viewModel.servicesViewGetAllCategoryData.message ?? 'Something went wrong',
                      style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        if (widget.serviceId != null) {
                          viewModel.fetchServicesViewGetAllCategoriesGetApi(widget.serviceId!);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(color: AppColors.button(context), borderRadius: BorderRadius.circular(100)),
                        child: Text('Retry', style: AppTextStyles.textSize14(context, color: AppColors.whiteColor)),
                      ),
                    ),
                  ],
                ),
              );

            case Status.COMPLETED:
              final categories = viewModel.servicesViewGetAllCategoryData.data?.data?.categories ?? [];

              if (categories.isEmpty) {
                return Center(
                  child: Text('No categories found', style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context))),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.all(16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _buildCategorySection(context, category);
                },
              );

            default:
              return SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, Category category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Row(
          children: [
            if (category.image != null && category.image!.isNotEmpty)
              Container(
                height: 36,
                width: 36,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.border(context)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: category.image!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Icon(Icons.category_outlined, color: AppColors.subtitle(context), size: 18),
                  ),
                ),
              ),
            Expanded(
              child: Text(category.name ?? '', style: AppTextStyles.textSize16(context, weight: FontWeight.w600)),
            ),
            if (category.totalTasks != null) Text('${category.totalTasks} tasks', style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
          ],
        ),

        SizedBox(height: 12),

        // Tasks Grid
        if (category.tasks != null && category.tasks!.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.75),
            itemCount: category.tasks!.length,
            itemBuilder: (context, index) {
              final task = category.tasks![index];
              return _buildTaskCard(context, task);
            },
          ),

        Divider(color: AppColors.border(context), thickness: 1, height: 24),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    final imageUrl = task.images != null && task.images!.isNotEmpty ? task.images!.first.url : null;

    return GestureDetector(
      onTap: () {
        debugPrint('Task tapped: ${task.id}');
        // TODO: navigate to task detail screen with task.id
      },
      child: Column(
        children: [
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 1, color: AppColors.border(context)),
            ),
            child: Center(
              child: Container(
                height: 70,
                width: 70,
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => Icon(Icons.handyman_outlined, color: AppColors.subtitle(context), size: 28),
                      )
                    : Icon(Icons.handyman_outlined, color: AppColors.subtitle(context), size: 28),
              ),
            ),
          ),
          SizedBox(height: 6),
          Text(
            task.name ?? '',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textSize12(context, weight: FontWeight.w500),
          ),
          if (task.price?.salePrice != null)
            Text(
              '৳${task.price!.salePrice}',
              style: AppTextStyles.textSize12(context, weight: FontWeight.w600, color: AppColors.textPrimary(context)),
            ),
        ],
      ),
    );
  }
}
