import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Menampilkan gambar dari aset lokal atau jaringan.
///
/// Path yang diawali `assets/` dibaca dari aset aplikasi, sedangkan path
/// yang diawali `http` dibaca dari jaringan. Bila gambar tidak tersedia
/// atau gagal dimuat, tampil placeholder abu terang dengan ikon gambar.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  /// Path aset (`assets/...`) atau URL gambar (`http...`).
  final String? path;

  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final String source = path?.trim() ?? '';

    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => const _ImagePlaceholder(),
      );
    }

    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => const _ImagePlaceholder(),
      );
    }

    return const _ImagePlaceholder();
  }
}

/// Placeholder netral saat gambar belum muncul atau gagal dimuat.
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.placeholder,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 36,
        color: AppColors.textSecondary,
      ),
    );
  }
}
