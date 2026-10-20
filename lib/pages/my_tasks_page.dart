import 'package:flutter/material.dart';

import '../models/task.dart';
import '../routes/app_routes.dart';
import '../services/app_state.dart';
import '../services/task_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/task_list_card.dart';

/// Halaman daftar tugas yang telah diambil oleh agen.
class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key, this.repository});

  /// Repository opsional agar mudah diganti saat memakai API atau diuji.
  final TaskRepository? repository;

  @override
  State<MyTasksPage> createState() => _MyTasksPageState();
}

class _MyTasksPageState extends State<MyTasksPage> {
  late final TaskRepository _repository;
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? LocalJsonRepository();
    _tasksFuture = _repository.getTasks();
  }

  void _reload() {
    setState(() {
      _tasksFuture = _repository.getTasks();
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
        title: const Text('Tugas Saya'),
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

          final List<Task> takenTasks = appState.takenTasksFrom(
            snapshot.data ?? const <Task>[],
          );

          if (takenTasks.isEmpty) {
            return const _EmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screen),
            itemCount: takenTasks.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (BuildContext context, int index) {
              final Task task = takenTasks[index];
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

/// Tampilan saat belum ada tugas yang diambil.
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
              Icons.task_alt_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Belum ada tugas yang diambil',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Ambil tugas dari beranda untuk melihatnya di sini.',
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
              'Gagal memuat tugas',
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
