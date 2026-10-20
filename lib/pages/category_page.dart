import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/task.dart';
import '../services/task_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../widgets/primary_button.dart';
import 'detail_page.dart';

/// Halaman daftar tugas berdasarkan kategori yang dipilih.
class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key, required this.category, this.repository});

  /// Kategori yang tugasnya sedang ditampilkan.
  final Category category;

  /// Repository opsional agar mudah diganti saat memakai API atau diuji.
  final TaskRepository? repository;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late final TaskRepository _repository;
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? LocalJsonRepository();
    _tasksFuture = _loadTasks();
  }

  Future<List<Task>> _loadTasks() {
    return _repository.getTasksByCategory(widget.category.id);
  }

  void _reload() {
    setState(() {
      _tasksFuture = _loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(widget.category.name),
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.accent),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Memuat tugas...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(onRetry: _reload);
          }

          final List<Task> tasks = snapshot.data ?? const <Task>[];
          if (tasks.isEmpty) {
            return const _EmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screen),
            itemCount: tasks.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (BuildContext context, int index) {
              final Task task = tasks[index];
              return _CategoryTaskCard(
                task: task,
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => DetailPage(task: task),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// Kartu tugas pada daftar kategori.
class _CategoryTaskCard extends StatelessWidget {
  const _CategoryTaskCard({required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.divider),
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
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
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
                        Expanded(
                          child: Text(
                            _formatRupiah(task.rate),
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          'Sampai ${_formatDueDate(task.deadline)}',
                          style: textTheme.bodySmall,
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

/// Tampilan saat kategori belum memiliki tugas.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.work_off_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Belum ada tugas',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tugas pada kategori ini belum tersedia. Coba lihat kategori lain.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tampilan saat daftar tugas gagal dimuat.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Gagal memuat data',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Periksa kembali data aplikasi, lalu coba lagi.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: 180,
              child: PrimaryButton(
                label: 'Coba lagi',
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ),
          ],
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

/// Mengubah tanggal tenggat menjadi format dd.MM.
String _formatDueDate(DateTime deadline) {
  final DateTime localDate = deadline.toLocal();
  final String day = localDate.day.toString().padLeft(2, '0');
  final String month = localDate.month.toString().padLeft(2, '0');
  return '$day.$month';
}
