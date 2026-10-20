import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/task.dart';
import '../services/task_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/category_tile.dart';
import '../widgets/filter_button.dart';
import '../widgets/primary_button.dart';
import '../widgets/task_card.dart';
import 'category_page.dart';
import 'detail_page.dart';
import 'map_page.dart';

/// Halaman beranda aplikasi Bantuin.
///
/// Menampilkan pencarian, tugas rekomendasi, dan daftar kategori.
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.repository});

  /// Repository opsional agar mudah diganti saat memakai API atau diuji.
  final TaskRepository? repository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TaskRepository _repository;
  late Future<_HomeData> _dataFuture;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _favoriteTaskIds = <String>{};
  String _query = '';

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? LocalJsonRepository();
    _dataFuture = _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<_HomeData> _loadData() async {
    final List<Category> categories = await _repository.getCategories();
    final List<Task> tasks = await _repository.getTasks();
    final Map<String, int> taskCounts = await _repository
        .countTasksByCategory();
    return _HomeData(
      categories: categories,
      tasks: tasks,
      taskCounts: taskCounts,
    );
  }

  void _reload() {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  /// Memfilter tugas secara lokal berdasarkan kata kunci pencarian.
  List<Task> _filterTasks(List<Task> tasks) {
    final String query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return tasks;
    }

    return tasks
        .where((Task task) {
          return task.title.toLowerCase().contains(query) ||
              task.description.toLowerCase().contains(query) ||
              task.location.toLowerCase().contains(query) ||
              task.posterName.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  void _toggleFavorite(String taskId) {
    setState(() {
      if (!_favoriteTaskIds.add(taskId)) {
        _favoriteTaskIds.remove(taskId);
      }
    });
  }

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.md,
                AppSpacing.screen,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppSearchBar(
                      controller: _searchController,
                      onChanged: (String value) {
                        setState(() => _query = value);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilterButton(
                    onTap: () => _showComingSoon('Filter tugas segera hadir.'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<_HomeData>(
                future: _dataFuture,
                builder:
                    (BuildContext context, AsyncSnapshot<_HomeData> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _LoadingState();
                      }
                      if (snapshot.hasError) {
                        return _ErrorState(onRetry: _reload);
                      }
                      return _buildContent(context, snapshot.data!);
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, _HomeData data) {
    final List<Task> tasks = _filterTasks(data.tasks)
        .take(4)
        .toList(growable: false);
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double cardWidth = (screenWidth * 0.78)
        .clamp(240.0, 320.0)
        .toDouble();
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: _SectionHeader(
              title: 'Direkomendasikan Untukmu',
              actionLabel: 'Lihat di peta',
              onAction: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        MapPage(repository: _repository),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 32,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Tugas tidak ditemukan.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                ),
                itemCount: tasks.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (BuildContext context, int index) {
                  final Task task = tasks[index];
                  return SizedBox(
                    width: cardWidth,
                    child: TaskCard.fromTask(
                      task,
                      isFavorite: _favoriteTaskIds.contains(task.id),
                      onTap: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => DetailPage(
                              task: task,
                              isFavorite: _favoriteTaskIds.contains(task.id),
                            ),
                          ),
                        );
                      },
                      onFavoriteTap: () => _toggleFavorite(task.id),
                      onChatTap: () =>
                          _showComingSoon('Chat pemosting segera hadir.'),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: _SectionHeader(
              title: 'Kategori',
              actionLabel: 'Lihat semua',
              onAction: () => _showComingSoon('Halaman kategori segera hadir.'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Column(
              children: [
                for (final Category category in data.categories) ...[
                  CategoryTile.fromCategory(
                    category,
                    taskCount: data.taskCounts[category.id] ?? 0,
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => CategoryPage(
                            category: category,
                            repository: _repository,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

/// Judul bagian dengan tautan aksi di sebelah kanan.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium,
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionLabel,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

/// Indikator saat data sedang dimuat.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.accent),
          const SizedBox(height: AppSpacing.sm),
          Text('Memuat tugas...', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Tampilan saat data gagal dimuat.
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

/// Gabungan data yang dibutuhkan beranda.
class _HomeData {
  const _HomeData({
    required this.categories,
    required this.tasks,
    required this.taskCounts,
  });

  final List<Category> categories;
  final List<Task> tasks;
  final Map<String, int> taskCounts;
}
