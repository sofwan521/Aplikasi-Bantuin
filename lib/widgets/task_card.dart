import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_theme.dart';
import 'app_image.dart';
import 'verified_avatar_chip.dart';

/// Kartu tugas pada beranda.
///
/// Berisi foto, label tenggat, ikon hati, chip pemosting, judul, dan ikon chat.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.title,
    required this.dueDate,
    required this.posterName,
    this.imageUrl,
    this.posterAvatarUrl,
    this.posterRating,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
    this.onChatTap,
  });

  /// Membuat kartu langsung dari model [Task].
  factory TaskCard.fromTask(
    Task task, {
    Key? key,
    bool isFavorite = false,
    VoidCallback? onTap,
    VoidCallback? onFavoriteTap,
    VoidCallback? onChatTap,
  }) {
    return TaskCard(
      key: key,
      title: task.title,
      dueDate: _formatDueDate(task.deadline),
      posterName: task.posterName,
      imageUrl: task.photoUrl,
      posterAvatarUrl: task.posterPhotoUrl,
      posterRating: task.rating,
      isFavorite: isFavorite,
      onTap: onTap,
      onFavoriteTap: onFavoriteTap,
      onChatTap: onChatTap,
    );
  }

  final String title;

  /// Tanggal tenggat dalam format dd.MM.
  final String dueDate;

  final String posterName;
  final String? imageUrl;
  final String? posterAvatarUrl;
  final double? posterRating;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onChatTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppImage(path: imageUrl, fit: BoxFit.cover),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: _DueDateLabel(dueDate: dueDate),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _CircleIconButton(
                          icon: isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite
                              ? AppColors.favorite
                              : AppColors.textPrimary,
                          onTap: onFavoriteTap,
                          tooltip: isFavorite
                              ? 'Hapus dari favorit'
                              : 'Tambah ke favorit',
                        ),
                      ),
                      Positioned(
                        left: 10,
                        right: 10,
                        bottom: 10,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: VerifiedAvatarChip(
                            name: posterName,
                            avatarUrl: posterAvatarUrl,
                            rating: posterRating,
                            backgroundColor: AppColors.surface.withValues(
                              alpha: 0.94,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _CircleIconButton(
                      icon: Icons.chat_bubble_outline,
                      onTap: onChatTap,
                      tooltip: 'Chat pemosting',
                      showBorder: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mengubah tanggal tenggat menjadi format dd.MM.
String _formatDueDate(DateTime deadline) {
  final DateTime localDate = deadline.toLocal();
  final String day = localDate.day.toString().padLeft(2, '0');
  final String month = localDate.month.toString().padLeft(2, '0');
  return '$day.$month';
}

/// Label tenggat berwarna putih di sudut foto.
class _DueDateLabel extends StatelessWidget {
  const _DueDateLabel({required this.dueDate});

  final String dueDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppRadius.categoryChip),
      ),
      child: Text(
        'Sampai $dueDate',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Tombol ikon bulat untuk aksi di dalam kartu.
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.color = AppColors.textPrimary,
    this.showBorder = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color color;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface,
        shape: CircleBorder(
          side: showBorder
              ? const BorderSide(color: AppColors.divider)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}
