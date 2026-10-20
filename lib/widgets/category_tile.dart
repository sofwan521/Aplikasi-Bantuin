import 'package:flutter/material.dart';

import '../models/category.dart';
import '../theme/app_theme.dart';

/// Memetakan nama ikon dari JSON ke ikon Material.
IconData categoryIconFromName(String iconName) {
  switch (iconName) {
    case 'local_shipping':
      return Icons.local_shipping_outlined;
    case 'home_repair_service':
      return Icons.home_repair_service_outlined;
    case 'pets':
      return Icons.pets_outlined;
    case 'shopping_bag':
      return Icons.shopping_bag_outlined;
    case 'cleaning_services':
      return Icons.cleaning_services_outlined;
    case 'menu_book':
      return Icons.menu_book_outlined;
    default:
      return Icons.grid_view_outlined;
  }
}

/// Item kategori berisi ikon, nama kategori, dan jumlah tugas.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.icon,
    required this.label,
    required this.taskCount,
    this.onTap,
  });

  /// Membuat tile langsung dari model [Category].
  factory CategoryTile.fromCategory(
    Category category, {
    Key? key,
    VoidCallback? onTap,
  }) {
    return CategoryTile(
      key: key,
      icon: categoryIconFromName(category.iconName),
      label: category.name,
      taskCount: category.offerCount,
      onTap: onTap,
    );
  }

  final IconData icon;
  final String label;
  final int taskCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppRadius.categoryChip),
                ),
                child: Icon(icon, color: AppColors.textPrimary, size: 22),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text('$taskCount tugas', style: textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
