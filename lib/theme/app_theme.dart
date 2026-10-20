import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet warna aplikasi Bantuin.
///
/// Semua warna dipusatkan di sini agar konsisten dan mudah diubah.
class AppColors {
  AppColors._();

  /// Kuning utama untuk tombol aksi dan filter.
  static const Color accent = Color(0xFFFFCC00);

  /// Latar layar abu sangat terang.
  static const Color background = Color(0xFFFAFAFA);

  /// Permukaan kartu dan kontainer.
  static const Color surface = Color(0xFFFFFFFF);

  /// Teks utama, judul, dan nominal Rupiah.
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Teks sekunder dan keterangan.
  static const Color textSecondary = Color(0xFF666666);

  /// Warna centang akun terverifikasi.
  static const Color verified = Color(0xFF00C853);

  /// Garis batas dan pemisah.
  static const Color divider = Color(0xFFE0E0E0);

  /// Latar placeholder foto saat gambar belum tersedia atau gagal dimuat.
  static const Color placeholder = Color(0xFFEEEEEE);

  /// Warna ikon hati saat tugas disukai.
  static const Color favorite = Color(0xFFE53935);
}

/// Radius sudut standar aplikasi.
class AppRadius {
  AppRadius._();

  static const double card = 16;
  static const double photo = 16;
  static const double button = 12;
  static const double searchBar = 12;
  static const double filterButton = 12;
  static const double avatar = 20;
  static const double categoryChip = 8;
}

/// Jarak dan ukuran standar aplikasi.
class AppSpacing {
  AppSpacing._();

  /// Padding kiri-kanan layar.
  static const double screen = 16;

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;

  /// Tinggi navigasi bawah.
  static const double bottomNav = 70;

  /// Tinggi tombol utama.
  static const double primaryButtonHeight = 50;
}

/// Bayangan standar aplikasi.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> primaryButton = [
    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
  ];
}

/// Tema utama aplikasi Bantuin.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final TextTheme baseTextTheme = GoogleFonts.montserratTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        primary: AppColors.accent,
        surface: AppColors.surface,
      ),
      fontFamily: GoogleFonts.montserrat().fontFamily,
      textTheme: baseTextTheme.copyWith(
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      dividerColor: AppColors.divider,
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    );
  }
}
