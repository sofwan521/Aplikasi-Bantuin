import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tombol filter kuning berisi ikon tanpa teks.
class FilterButton extends StatelessWidget {
  const FilterButton({
    super.key,
    required this.onTap,
    this.icon = Icons.tune,
    this.size = 52,
    this.tooltip = 'Filter',
  });

  final VoidCallback onTap;
  final IconData icon;
  final double size;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.filterButton),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.filterButton),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: AppColors.textPrimary, size: 24),
          ),
        ),
      ),
    );
  }
}
