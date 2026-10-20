import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_theme.dart';
import 'app_image.dart';

/// Kartu tugas berbentuk baris untuk daftar kategori dan favorit.
class TaskListCard extends StatelessWidget {
  const TaskListCard({
    super.key,
    required this.task,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  final Task task;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.transparent,
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.photo),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: AppImage(path: task.photoUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium,
                          ),
                        ),
                        if (onFavoriteTap != null)
                          IconButton(
                            onPressed: onFavoriteTap,
                            tooltip: isFavorite
                                ? 'Hapus dari favorit'
                                : 'Tambah ke favorit',
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                              width: 32,
                              height: 32,
                            ),
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? AppColors.favorite
                                  : AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            task.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Tarif mendapat ruang lebih besar agar tidak terpotong.
                        Expanded(
                          flex: 3,
                          child: Text(
                            formatRupiah(task.rate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 2,
                          child: Text(
                            'Sampai ${formatDueDate(task.deadline)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: textTheme.bodySmall,
                          ),
                        ),
                      ],
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

/// Mengubah nominal menjadi format Rupiah, misalnya "Rp 100.000".
String formatRupiah(int amount) {
  final String value = amount.toString();
  final StringBuffer buffer = StringBuffer();

  for (int index = 0; index < value.length; index++) {
    buffer.write(value[index]);
    final int remaining = value.length - index - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write('.');
    }
  }

  return 'Rp $buffer';
}

/// Mengubah tanggal tenggat menjadi format dd.MM.
String formatDueDate(DateTime deadline) {
  final DateTime localDate = deadline.toLocal();
  final String day = localDate.day.toString().padLeft(2, '0');
  final String month = localDate.month.toString().padLeft(2, '0');
  return '$day.$month';
}
