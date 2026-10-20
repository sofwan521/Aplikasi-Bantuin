import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/task.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../widgets/primary_button.dart';
import '../widgets/verified_avatar_chip.dart';

/// Halaman detail tugas dengan foto header dan aksi mengambil tugas.
class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.task});

  /// Tugas yang detailnya sedang ditampilkan.
  final Task task;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late bool _isTaken;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isTaken = widget.task.status == TaskStatus.taken;
    _isCompleted = widget.task.status == TaskStatus.completed;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Meminta konfirmasi sebelum tugas diambil.
  Future<void> _confirmTakeTask() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ambil tugas ini?'),
          content: Text(
            'Kamu akan mengambil "${widget.task.title}". '
            'Pastikan kamu siap mengerjakannya.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ambil'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() {
      _isTaken = true;
    });
    _showMessage('Tugas berhasil diambil');
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = AppStateScope.of(context);
    final double photoHeight = (MediaQuery.sizeOf(context).height * 0.38)
        .clamp(260.0, 360.0)
        .toDouble();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PhotoHeader(
                      task: widget.task,
                      height: photoHeight,
                      onBack: () => Navigator.of(context).maybePop(),
                      onShare: () =>
                          _showMessage('Fitur bagikan segera hadir.'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.screen),
                      child: _DetailContent(
                        task: widget.task,
                        isFavorite: appState.isFavorite(widget.task.id),
                        onFavoriteTap: () =>
                            appState.toggleFavorite(widget.task.id),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BottomActionBar(
              isTaken: _isTaken,
              isCompleted: _isCompleted,
              onChatTap: () => _showMessage('Chat pemosting segera hadir.'),
              onTakeTap: _confirmTakeTask,
            ),
          ],
        ),
      ),
    );
  }
}

/// Header foto tugas dengan tombol kembali, bagikan, dan chip pemosting.
class _PhotoHeader extends StatelessWidget {
  const _PhotoHeader({
    required this.task,
    required this.height,
    required this.onBack,
    required this.onShare,
  });

  final Task task;
  final double height;
  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(AppRadius.photo),
            ),
            child: AppImage(path: task.photoUrl, fit: BoxFit.cover),
          ),
          Positioned(
            top: topPadding + AppSpacing.xs,
            left: AppSpacing.screen,
            child: _CircleActionButton(
              icon: Icons.arrow_back,
              tooltip: 'Kembali',
              onTap: onBack,
            ),
          ),
          Positioned(
            top: topPadding + AppSpacing.xs,
            right: AppSpacing.screen,
            child: _CircleActionButton(
              icon: Icons.ios_share,
              tooltip: 'Bagikan',
              onTap: onShare,
            ),
          ),
          Positioned(
            left: AppSpacing.screen,
            bottom: AppSpacing.md,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                // Sisakan ruang untuk label tenggat di sisi kanan foto.
                maxWidth: MediaQuery.sizeOf(context).width * 0.5,
              ),
              child: VerifiedAvatarChip(
                name: task.posterName,
                avatarUrl: task.posterPhotoUrl,
                rating: task.rating,
                backgroundColor: AppColors.surface.withValues(alpha: 0.94),
              ),
            ),
          ),
          Positioned(
            right: AppSpacing.screen,
            bottom: AppSpacing.md,
            child: _DueDateChip(deadline: task.deadline),
          ),
        ],
      ),
    );
  }
}

/// Tombol ikon bulat putih di atas foto.
class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface.withValues(alpha: 0.94),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(icon, size: 20, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// Label tenggat pada sudut kanan bawah foto.
class _DueDateChip extends StatelessWidget {
  const _DueDateChip({required this.deadline});

  final DateTime deadline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppRadius.categoryChip),
      ),
      child: Text(
        'Sampai ${_formatDueDate(deadline)}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Isi detail tugas: judul, deskripsi, tarif, dan lokasi.
class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.task,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final Task task;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(task.title, style: textTheme.headlineSmall)),
            const SizedBox(width: AppSpacing.xs),
            IconButton(
              onPressed: onFavoriteTap,
              tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? AppColors.favorite : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          task.description,
          style: textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Text('Tarif', style: textTheme.bodyLarge),
            const SizedBox(width: AppSpacing.xs),
            Text(
              _formatRupiah(task.rate),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const Icon(
              Icons.place_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                task.location,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              _formatDistance(task.distanceMeters),
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

/// Baris aksi bawah: tombol chat dan tombol ambil tugas.
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.isTaken,
    required this.isCompleted,
    required this.onChatTap,
    required this.onTakeTap,
  });

  final bool isTaken;
  final bool isCompleted;
  final VoidCallback onChatTap;
  final VoidCallback onTakeTap;

  @override
  Widget build(BuildContext context) {
    final bool canTake = !isTaken && !isCompleted;
    final String takeLabel = isCompleted
        ? 'Tugas Selesai'
        : isTaken
        ? 'Sudah Diambil'
        : 'Ambil';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm,
            AppSpacing.screen,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Tooltip(
                message: 'Chat pemosting',
                child: Material(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onChatTap,
                    child: const SizedBox(
                      width: 56,
                      height: AppSpacing.primaryButtonHeight,
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PrimaryButton(
                  label: takeLabel,
                  onPressed: canTake ? onTakeTap : null,
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
String _formatRupiah(int amount) {
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

/// Mengubah jarak meter menjadi teks yang mudah dibaca.
String _formatDistance(int meters) {
  if (meters < 1000) {
    return '$meters m dari kamu';
  }

  final String value = (meters / 1000).toStringAsFixed(1).replaceAll('.', ',');
  return '$value km dari kamu';
}

/// Mengubah tanggal tenggat menjadi format dd.MM.
String _formatDueDate(DateTime deadline) {
  final DateTime localDate = deadline.toLocal();
  final String day = localDate.day.toString().padLeft(2, '0');
  final String month = localDate.month.toString().padLeft(2, '0');
  return '$day.$month';
}
