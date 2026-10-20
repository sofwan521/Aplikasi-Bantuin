import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/task.dart';
import '../routes/app_routes.dart';
import '../services/app_state.dart';
import '../services/task_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/task_list_card.dart';

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
    final AppState appState = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          widget.category.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
              return TaskListCard(
                task: task,
                isFavorite: appState.isFavorite(task.id),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(AppRoutes.detail, arguments: task);
                },
                onFavoriteTap: () => appState.toggleFavorite(task.id),
              );
            },
          );
        },
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
