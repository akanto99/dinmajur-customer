import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/components/circle_network_image/circle_network_image.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:dinmajur_customer/model/order_models/get_all_order_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AssignedFreelancerSection extends StatelessWidget {
  final Datum datum;
  final bool showActions; // false on completed tab

  const AssignedFreelancerSection({
    super.key,
    required this.datum,
    this.showActions = true,
  });

  String get _displayName {
    final first = datum.freelancer?.firstName ?? '';
    final last = datum.freelancer?.lastName ?? '';
    final full = '$first $last'.trim();
    return full.isNotEmpty ? full : 'Freelancer';
  }

  String get _role {
    final f = datum.freelancer;
    if (f == null) return '';
    if (f.skills != null && f.skills!.isNotEmpty) {
      return f.skills!.first.category ?? f.role ?? '';
    }
    return f.role ?? '';
  }

  String? get _imageUrl => datum.freelancer?.profilePicture?.url;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ASSIGNED FREELANCER",
          style: AppTextStyles.textSize12(
            context,
            weight: FontWeight.w500,
            color: AppColors.subtitle(context),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(width: 1, color: AppColors.border(context)),
          ),
          child: Row(
            children: [
              CircleAvatarNetwork(
                imageUrl: _imageUrl,
                name: _displayName,
                size: 44,
                borderWidth: 1.5,
                borderColor: AppColors.border(context),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName,
                      style: AppTextStyles.textSize14(context, weight: FontWeight.w500),
                    ),
                    if (_role.isNotEmpty)
                      Text(
                        _role,
                        style: AppTextStyles.textSize12(
                          context,
                          color: AppColors.subtitle(context),
                        ),
                      ),
                    Row(
                      children: [
                        const Icon(FontAwesomeIcons.solidStar,
                            color: Color(0xFFFACC15), size: 11),
                        const SizedBox(width: 4),
                        Text(
                          "0.0",
                          style: AppTextStyles.textSize12(context, weight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (showActions) ...[
                _CircleActionButton(
                  icon: FontAwesomeIcons.solidComment,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _CircleActionButton(
                  icon: FontAwesomeIcons.phone,
                  onTap: () {},
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 31,
        height: 31,
        decoration: BoxDecoration(
          color: AppColors.textPrimary(context),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.containerBackground(context), size: 12),
      ),
    );
  }
}