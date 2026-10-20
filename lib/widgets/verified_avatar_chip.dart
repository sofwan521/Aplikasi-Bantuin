import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Chip avatar pengguna dengan centang hijau terverifikasi.
class VerifiedAvatarChip extends StatelessWidget {
  const VerifiedAvatarChip({
    super.key,
    required this.name,
    this.avatarUrl,
    this.rating,
    this.avatarRadius = 15,
    this.backgroundColor = AppColors.surface,
    this.padding = const EdgeInsets.fromLTRB(4, 4, 10, 4),
  });

  final String name;
  final String? avatarUrl;

  /// Rating pemosting, ditampilkan bila tidak null.
  final double? rating;

  final double avatarRadius;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.avatar),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Avatar(name: name, avatarUrl: avatarUrl, radius: avatarRadius),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (rating != null) ...[
            const SizedBox(width: 4),
            const Icon(Icons.star, size: 12, color: AppColors.accent),
            const SizedBox(width: 2),
            Text(
              rating!.toStringAsFixed(1),
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Avatar bulat dengan centang verifikasi di sudut kanan bawah.
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.name,
    required this.avatarUrl,
    required this.radius,
  });

  final String name;
  final String? avatarUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final double diameter = radius * 2;
    final String initial = name.trim().isEmpty
        ? '?'
        : name.trim().characters.first.toUpperCase();

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: avatarUrl == null || avatarUrl!.isEmpty
                ? _fallbackAvatar(context, initial)
                : Image.network(
                    avatarUrl!,
                    width: diameter,
                    height: diameter,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _fallbackAvatar(context, initial),
                  ),
          ),
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppColors.verified,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 10,
                color: AppColors.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackAvatar(BuildContext context, String initial) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: AppColors.accent,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
