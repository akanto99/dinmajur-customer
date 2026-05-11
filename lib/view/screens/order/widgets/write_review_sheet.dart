import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/circle_network_image/circle_network_image.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:dinmajur_customer/view_model/homeview_model/nearby_retailers_and_order_view_models/order_now_view_models/freelancer_rating_view_model.dart';
import 'package:dinmajur_customer/view_model/order_view_models/running_orders_view_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

void showWriteReviewSheet(BuildContext context, Datum datum, String bookingId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _WriteReviewSheet(datum: datum, bookingId: bookingId),
  );
}

// ─── Private StatefulWidget ───────────────────────────────────────────────────
class _WriteReviewSheet extends StatefulWidget {
  final Datum datum;
  final String bookingId;

  const _WriteReviewSheet({required this.datum, required this.bookingId});

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  int _selectedRating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  int _charCount = 0;

  // ─── Helpers ─────────────────────────────────────────────────────────────
  String get _freelancerName {
    final first = widget.datum.freelancer?.firstName ?? '';
    final last = widget.datum.freelancer?.lastName ?? '';
    final full = '$first $last'.trim();
    return full.isNotEmpty ? full : 'Freelancer';
  }

  String? get _imageUrl => widget.datum.freelancer?.profilePicture?.url;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
  Future<void> _onSubmit() async {
    if (_selectedRating == 0) {
      Utils.flushBarErrorMessage("Please select a rating", context);
      return;
    }

    final String freelancerId = widget.datum.type == 'ORDER'
        ? widget.datum.freelancerId ?? ''
        : widget.datum.freelancer?.id ?? '';
    if (freelancerId.isEmpty) {
      Utils.flushBarErrorMessage("Freelancer not found", context);
      return;
    }

    final Map<String, dynamic> fields = {
      "referenceId": widget.datum.id,
      "referenceType": widget.datum.type ?? '',
      "targetId": freelancerId,
      "targetType": "FREELANCER",
      "rating": _selectedRating,
      "review": _feedbackController.text.trim(),
    };

    final navigator = Navigator.of(context);
    final orderVm = context.read<RunningOrdersViewModel>();

    await context.read<PatchFreelancerRatingViewModel>().FreelancerRatingPatchApi(
      context,
      fields,
      onSuccess: () {
        navigator.pop();
        orderVm.refreshSingleOrder(widget.bookingId);
      },
    );
  }
  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<PatchFreelancerRatingViewModel>(
      builder: (context, freelancerRatingModel, child) {
        final bool isLoading = freelancerRatingModel.createFreelancerRatingLoading;

        return SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(top: 80),
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Handle bar ────────────────────────────────────────────────
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(color: AppColors.border(context), borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 20),
          
                // ── Title ─────────────────────────────────────────────────────
                Text("Write a Review", style: AppTextStyles.textSize20(context, weight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  "Please rate your experience with the freelancer.",
                  style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
          
                // ── Freelancer avatar ─────────────────────────────────────────
                CircleAvatarNetwork(imageUrl: _imageUrl, name: _freelancerName, size: 72, borderWidth: 2.0, borderColor: AppColors.button(context)),
                const SizedBox(height: 12),
          
                Text(_freelancerName, style: AppTextStyles.textSize18(context, weight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text("How was their work?", style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context))),
                const SizedBox(height: 16),
          
                // ── Star rating ───────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: isLoading ? null : () => setState(() => _selectedRating = index + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          _selectedRating > index ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
                          color: _selectedRating > index ? const Color(0xFFFACC15) : AppColors.border(context),
                          size: 28,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
          
                // ── Feedback field ────────────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Additional Feedback", style: AppTextStyles.textSize14(context, weight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
          
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.hintColor(context).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: TextField(
                    controller: _feedbackController,
                    maxLines: 4,
                    maxLength: 250,
                    enabled: !isLoading,
                    onChanged: (val) => setState(() => _charCount = val.length),
                    decoration: InputDecoration(
                      hintText: "Write your feedback here...",
                      hintStyle: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      counterText: "$_charCount/250",
                      counterStyle: AppTextStyles.textSize10(context, color: AppColors.subtitle(context)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
          
                // ── Buttons ───────────────────────────────────────────────────
                Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: GestureDetector(
                        onTap: isLoading ? null : () => Navigator.of(context).pop(),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(color: AppColors.hintColor(context).withOpacity(isLoading ? 0.05 : 0.15), borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(
                              "Cancel",
                              style: AppTextStyles.textSize14(context, weight: FontWeight.w500, color: isLoading ? AppColors.subtitle(context) : AppColors.textPrimary(context)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
          
                    // Submit
                    Expanded(
                      child: GestureDetector(
                        onTap: isLoading ? null : _onSubmit,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(color: AppColors.textPrimary(context), borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: isLoading
                                ? LoadingAnimationWidget.progressiveDots(color: AppColors.textSecondary(context), size: 36)
                                : Text(
                                    "Submit Review",
                                    style: AppTextStyles.textSize14(context, weight: FontWeight.w600, color: AppColors.textSecondary(context)),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
