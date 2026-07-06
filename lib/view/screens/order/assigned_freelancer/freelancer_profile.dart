import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/circle_network_image/circle_network_image.dart';
import 'package:dinmajur_customer/configs/res/components/header_appbar.dart';
import 'package:dinmajur_customer/configs/res/sizedbox_spaccing.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/data/response/status.dart';
import 'package:dinmajur_customer/model/order_models/assigned_freelance_model/freelancer_review_model.dart';
import 'package:dinmajur_customer/view_model/order_view_models/assigned_freelance_view_model/freelancer_review_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class FreelancerProfileScreen extends StatefulWidget {
  const FreelancerProfileScreen({super.key});

  @override
  State<FreelancerProfileScreen> createState() => _FreelancerProfileScreenState();
}

class _FreelancerProfileScreenState extends State<FreelancerProfileScreen> {
  final FreelancerReviewViewModel _viewModel = FreelancerReviewViewModel();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final freelancerID = ModalRoute.of(context)?.settings.arguments as String? ?? '';
      _viewModel.fetchReviewsDataApi(freelancerID);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.containerBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            GestureDetector(onTap: () => Navigator.pop(context), child: AppBarHeader("Freelancer Profile")),
            Expanded(
              child: ChangeNotifierProvider<FreelancerReviewViewModel>.value(
                value: _viewModel,
                child: Consumer<FreelancerReviewViewModel>(
                  builder: (context, viewModel, _) {
                    switch (viewModel.reViewData.status) {
                      case Status.LOADING:
                        return Center(child: LoadingAnimationWidget.progressiveDots(color: AppColors.button(context), size: 50));

                      case Status.ERROR:
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(viewModel.reViewData.message ?? 'Something went wrong', textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  final freelancerID = ModalRoute.of(context)?.settings.arguments as String? ?? '';
                                  viewModel.fetchReviewsDataApi(freelancerID);
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.button(context)),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );

                      case Status.COMPLETED:
                        final data = viewModel.reViewData.data?.data;
                        if (data == null) return const Center(child: Text('No data found'));
                        return _buildContent(context, data);

                      default:
                        return const SizedBox();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Data data) {

    final sw = MediaQuery.of(context).size.width;
    final freelancer = data.freelancer;
    final stats = data.stats;
    final summary = data.reviewsSummery;
    final reviews = data.reviews ?? [];

    final displayName = '${freelancer?.firstName ?? ''} ${freelancer?.lastName ?? ''}'.trim();
    final skillCategories = freelancer?.skills?.map((s) => s.category ?? '').where((c) => c.isNotEmpty).join(' · ') ?? '';
    final experience = freelancer?.experience ?? 0;
    final avgRating = (summary?.avgRating ?? 0).toDouble();
    final totalReviews = summary?.totalReviews ?? 0;
    final freelancerProfile = freelancer?.profilePicture?.url;

    final freelancerID =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<FreelancerReviewViewModel>()
            .fetchReviewsDataApi(freelancerID);
      },
      color: AppColors.textPrimary(context),
      backgroundColor: AppColors.containerBackground(context),
      displacement: 40,
      strokeWidth: 2.0,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatarNetwork(
                  imageUrl: freelancerProfile,
                  name: displayName,
                  size: 68,
                  borderWidth: 1,
                  borderColor: AppColors.border(context),
                ),              SizedboxSpaccing.width03(context),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: AppTextStyles.textSize16(context, weight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      if (skillCategories.isNotEmpty)
                        Text(
                          skillCategories,
                          style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 5),
                      if (experience > 0)
                        Row(
                          children: [
                            Icon(FontAwesomeIcons.clock, size: 12, color: AppColors.subtitle(context)),
                            const SizedBox(width: 4),
                            Text('$experience years experience', style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
                          ],
                        ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(i < avgRating.floor() ? Icons.star_rounded : (i < avgRating ? Icons.star_half_rounded : Icons.star_outline_rounded), size: 14, color: const Color(0xFFF59E0B)),
                          ),
                          const SizedBox(width: 4),
                          Text('${avgRating.toStringAsFixed(1)} · $totalReviews reviews', style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedboxSpaccing.height02(context),
            Container(height: 2.5, color: AppColors.border(context)),
            SizedboxSpaccing.height02(context),

            _buildSection(context, 'ORDER STATISTICS', _buildStatsTable(context, stats)),
            SizedboxSpaccing.height02(context),

            _buildSection(context, 'RATINGS', _buildRatingSummary(context, summary)),
            SizedboxSpaccing.height02(context),

            Text(
              'REVIEWS',
              style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
            ),
            SizedboxSpaccing.height02(context),
            _buildReviews(context, reviews),
            SizedboxSpaccing.height025(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTable(BuildContext context, Stats? stats) {
    final totalOrders = stats?.totalOrders ?? 0;
    final completedOrders = stats?.completedOrders ?? 0;
    final cancelledOrders = stats?.cancelledOrders ?? 0;
    final runningOrders = stats?.runningOrders ?? 0;
    final pendingOrders = stats?.pendingOrders ?? 0;
    final completionRate = stats?.pendingCompletionRate ?? 0.0;

    final cells = [
      ('$totalOrders', 'Total Orders'),
      ('$completedOrders', 'Completed'),
      ('$cancelledOrders', 'Cancelled'),
      ('$runningOrders', 'Running'),
      ('$pendingOrders', 'Pending'),
      ('${completionRate.toStringAsFixed(0)}%', 'Completion'),
    ];

    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          child: Table(
            border: TableBorder(
              horizontalInside: BorderSide(color: AppColors.border(context), width: 0.2),
              verticalInside: BorderSide(color: AppColors.border(context), width: 0.2),
            ),
            children: [
              TableRow(children: [_statCell(context, cells[0].$1, cells[0].$2), _statCell(context, cells[1].$1, cells[1].$2), _statCell(context, cells[2].$1, cells[2].$2)]),
              TableRow(children: [_statCell(context, cells[3].$1, cells[3].$2), _statCell(context, cells[4].$1, cells[4].$2), _statCell(context, cells[5].$1, cells[5].$2)]),
            ],
          ),
        ),
        Divider(height: 1, color: AppColors.border(context)),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Completion Rate', style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
                  Text('${completionRate.toStringAsFixed(1)}%', style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: completionRate / 100, minHeight: 6, color: AppColors.button(context), backgroundColor: AppColors.border(context)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCell(BuildContext context, String val, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Text(val, style: AppTextStyles.textSize20(context, weight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(BuildContext context, ReviewsSummery? summary) {
    final avgRating = (summary?.avgRating ?? 0).toDouble();
    final totalReviews = summary?.totalReviews ?? 0;
    final breakdown = summary?.ratingBreakdown ?? {};
    final total = breakdown.values.fold(0, (sum, val) => sum + val);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating bars
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final star = 5 - index;
                final count = breakdown[star.toString()] ?? 0;
                final ratio = total == 0 ? 0.0 : count / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$star', style: AppTextStyles.textSize12(context)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: ratio,
                          color: AppColors.button(context),
                          backgroundColor: AppColors.border(context),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 16),
          // Avg rating display
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: AppTextStyles.textSize36(context, weight: FontWeight.bold, color: AppColors.textPrimary(context)),
              ),
              Row(children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < avgRating ? const Color(0xFFF59E0B) : Colors.grey))),
              const SizedBox(height: 4),
              Text('$totalReviews reviews', style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviews(BuildContext context, List<Review> reviews) {
    if (reviews.isEmpty) {
      return Center(
        child: Text('No reviews yet', style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context))),
      );
    }

    return Column(
      children: reviews.map((r) {
        final name = r.reviewer?.fullName ?? 'Unknown';
        final imageUrl = r.reviewer?.profilePicture?.url;
        final stars = r.rating ?? 0;
        final comment = r.review ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 10), // space between cards
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            // borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatarNetwork(imageUrl: imageUrl, name: name, size: 38, borderWidth: 1, borderColor: AppColors.border(context)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.textSize14(context, weight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Row(children: List.generate(5, (i) => Icon(Icons.star, size: 12, color: i < stars ? const Color(0xFFF59E0B) : Colors.grey))),
                    if (comment.isNotEmpty) ...[const SizedBox(height: 4), Text(comment, style: AppTextStyles.textSize12(context, color: AppColors.subtitle(context)))],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSection(BuildContext context, String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.textSize16(context, weight: FontWeight.w500, color: AppColors.textPrimary(context)),
        ),
        SizedboxSpaccing.height02(context),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.containerBackground(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: child,
        ),
      ],
    );
  }
}
