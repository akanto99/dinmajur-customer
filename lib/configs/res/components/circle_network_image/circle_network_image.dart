import 'package:dinmajur_customer/configs/res/color.dart';
import 'package:dinmajur_customer/configs/res/text_styles.dart';
import 'package:flutter/material.dart';

/// ```
class CircleAvatarNetwork extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final double borderWidth;
  final Color? borderColor;
  final Color? backgroundColor;
  final BoxFit fit;

  const CircleAvatarNetwork({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 72,
    this.borderWidth = 2.0,
    this.borderColor,
    this.backgroundColor,
    this.fit = BoxFit.cover,
  });

  /// Generates up to 2 initials from [name].
  String _initials() {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || name.trim().isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final Color effectiveBorderColor = borderColor ?? AppColors.button(context);
    final Color effectiveBg = backgroundColor ?? AppColors.hintColor(context).withOpacity(0.25);
    final double fontSize = size * 0.30; // initials scale with size

    final bool hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildFallback(context, effectiveBg, fontSize);
          },
          errorBuilder: (context, error, stackTrace) =>
              _buildFallback(context, effectiveBg, fontSize),
        )
            : _buildFallback(context, effectiveBg, fontSize),
      ),
    );
  }

  Widget _buildFallback(BuildContext context, Color bg, double fontSize) {
    return Container(
      width: size,
      height: size,
      color: bg,
      alignment: Alignment.center,
      child: Text(
        _initials(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary(context),
        ),
      ),
    );
  }
}