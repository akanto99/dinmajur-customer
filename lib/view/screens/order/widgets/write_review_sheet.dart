import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/circle_network_image/circle_network_image.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/configs/utils/utils.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void showWriteReviewSheet(BuildContext context, Datum datum) {
  int selectedRating = 0;
  final TextEditingController feedbackController = TextEditingController();
  int charCount = 0;

  final String? imageUrl = datum.freelancer?.profilePicture?.url;
  final String freelancerName =
  '${datum.freelancer?.firstName ?? ''} ${datum.freelancer?.lastName ?? ''}'.trim();
  final String displayName = freelancerName.isNotEmpty ? freelancerName : 'Freelancer';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            margin: const EdgeInsets.only(top: 80),
            decoration: BoxDecoration(
              color: AppColors.containerBackground(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "Write a Review",
                  style: AppTextStyles.textSize20(context, weight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  "Please rate your experience with the freelancer.",
                  style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                CircleAvatarNetwork(
                  imageUrl: imageUrl,
                  name: displayName,
                  size: 72,
                  borderWidth: 2.0,
                  borderColor: AppColors.button(context),
                ),
                const SizedBox(height: 12),

                Text(
                  displayName,
                  style: AppTextStyles.textSize18(context, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  "How was their work?",
                  style: AppTextStyles.textSize14(context, color: AppColors.subtitle(context)),
                ),
                const SizedBox(height: 16),

                // Star Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedRating = index + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          selectedRating > index
                              ? FontAwesomeIcons.solidStar
                              : FontAwesomeIcons.star,
                          color: selectedRating > index
                              ? const Color(0xFFFACC15)
                              : AppColors.border(context),
                          size: 28,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Additional Feedback",
                    style: AppTextStyles.textSize14(context, weight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.hintColor(context).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: TextField(
                    controller: feedbackController,
                    maxLines: 4,
                    maxLength: 250,
                    onChanged: (val) => setModalState(() => charCount = val.length),
                    decoration: InputDecoration(
                      hintText: "Write your feedback here...",
                      hintStyle: AppTextStyles.textSize14(
                          context, color: AppColors.subtitle(context)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      counterText: "$charCount/250",
                      counterStyle: AppTextStyles.textSize10(
                          context, color: AppColors.subtitle(context)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.hintColor(context).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "Cancel",
                              style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (selectedRating == 0) {
                            Utils.flushBarErrorMessage("Please select a rating", context);
                            return;
                          }
                          Navigator.of(context).pop();
                          Utils.flushBarSuccessMessage(
                              "Review submitted successfully!", context);
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "Submit Review",
                              style: AppTextStyles.textSize14(
                                context,
                                weight: FontWeight.w600,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}