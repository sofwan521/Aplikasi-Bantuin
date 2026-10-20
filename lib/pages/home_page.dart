import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/task.dart';
import '../routes/app_routes.dart';
import '../services/app_state.dart';
import '../services/task_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/category_tile.dart';
import '../widgets/filter_button.dart';
import '../widgets/primary_button.dart';
import '../widgets/task_card.dart';
import '../widgets/task_list_card.dart';

/// Halaman beranda aplikasi Bantuin.
///
/// Menampilkan pencarian, tugas rekomendasi, dan daftar kategori. Pencarian
/// dan filter bekerja pada seluruh tugas, bukan hanya empat rekomendasi.
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
  String _query = '';
  _TaskFilter _filter = const _TaskFilter();

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

  /// Memfilter seluruh tugas berdasarkan kata kunci dan filter aktif.
  List<Task> _filterTasks(List<Task> tasks) {
    final String query = _query.trim().toLowerCase();
    final RangeValues? rateRange = _filter.rateRange;

    return tasks
        .where((Task task) {
          final bool matchesQuery =
              query.isEmpty ||
              task.title.toLowerCase().contains(query) ||
              task.description.toLowerCase().contains(query) ||
              task.location.toLowerCase().contains(query);
          final bool matchesCategory =
              _filter.categoryId == null ||
              task.categoryId == _filter.categoryId;
          final bool matchesRate =
              rateRange == null ||
              (task.rate >= rateRange.start && task.rate <= rateRange.end);
          return matchesQuery && matchesCategory && matchesRate;
        })
        .toList(growable: false);
  }

  bool get _isSearchOrFilterActive =>
      _query.trim().isNotEmpty || _filter.isActive;

  /// Membuka bottom sheet filter kategori dan rentang tarif.
  Future<void> _openFilterSheet() async {
    FocusScope.of(context).unfocus();

    late final _HomeData data;
    try {
      data = await _dataFuture;
    } catch (_) {
      return;
    }

    if (!mounted) {
      return;
    }

    final _TaskFilter? filter = await showModalBottomSheet<_TaskFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return _FilterSheet(
          categories: data.categories,
          tasks: data.tasks,
          initialFilter: _filter,
        );
      },
    );

    if (!mounted || filter == null) {
      return;
    }

    setState(() {
      _filter = filter;
    });
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Fitur ini akan tersedia pada pengembangan berikutnya'),
        ),
      );
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
                  FilterButton(onTap: _openFilterSheet),
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
    final List<Task> filteredTasks = _filterTasks(data.tasks);
    if (_isSearchOrFilterActive) {
      return _SearchResults(tasks: filteredTasks);
    }

    return _buildHomeSections(context, data);
  }

  Widget _buildHomeSections(BuildContext context, _HomeData data) {
    final AppState appState = AppStateScope.of(context);
    final List<Task> recommended = data.tasks.take(4).toList(growable: false);
    final Size screenSize = MediaQuery.sizeOf(context);
    final double cardWidth = (screenSize.width * 0.78)
        .clamp(240.0, 320.0)
        .toDouble();
    // Tinggi kartu menyesuaikan layar agar tetap proporsional di ponsel kecil.
    final double cardHeight = (screenSize.height * 0.33)
        .clamp(220.0, 280.0)
        .toDouble();
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: _SectionHeader(
              title: 'Direkomendasikan Untukmu',
              actionLabel: 'Lihat di peta',
              onAction: () {
                Navigator.of(context).pushNamed(AppRoutes.map);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (recommended.isEmpty)
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
                  boxShadow: AppShadows.card,
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
              height: cardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                ),
                itemCount: recommended.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (BuildContext context, int index) {
                  final Task task = recommended[index];
                  return SizedBox(
                    width: cardWidth,
                    child: TaskCard.fromTask(
                      task,
                      isFavorite: appState.isFavorite(task.id),
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.detail, arguments: task);
                      },
                      onFavoriteTap: () => appState.toggleFavorite(task.id),
                      onChatTap: _showComingSoon,
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: _SectionHeader(
              title: 'Kategori',
              actionLabel: 'Lihat semua',
              onAction: _showComingSoon,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: data.categories.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      boxShadow: AppShadows.card,
                    ),
                    child: Text(
                      'Belum ada kategori.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall,
                    ),
                  )
                : Column(
                    children: [
                      for (final Category category in data.categories) ...[
                        CategoryTile.fromCategory(
                          category,
                          taskCount: data.taskCounts[category.id] ?? 0,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.category,
                              arguments: category,
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

/// Daftar hasil pencarian dan filter dalam bentuk kartu vertikal.
class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final AppState appState = AppStateScope.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isEmpty = tasks.isEmpty;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        AppSpacing.md,
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: isEmpty ? 2 : tasks.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Text('${tasks.length} hasil', style: textTheme.titleMedium);
        }

        if (isEmpty) {
          return const _EmptySearchResult();
        }

        final Task task = tasks[index - 1];
        return TaskListCard(
          task: task,
          isFavorite: appState.isFavorite(task.id),
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.detail, arguments: task);
          },
          onFavoriteTap: () => appState.toggleFavorite(task.id),
        );
      },
    );
  }
}

/// Empty state saat pencarian atau filter tidak menemukan tugas.
class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
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
            'Tugas tidak ditemukan',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter aktif yang dipilih pengguna pada beranda.
class _TaskFilter {
  const _TaskFilter({this.categoryId, this.rateRange});

  final String? categoryId;
  final RangeValues? rateRange;

  bool get isActive => categoryId != null || rateRange != null;
}

/// Bottom sheet untuk memilih kategori dan rentang tarif.
class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.categories,
    required this.tasks,
    required this.initialFilter,
  });

  final List<Category> categories;
  final List<Task> tasks;
  final _TaskFilter initialFilter;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late double _minRate;
  late double _maxRate;
  late RangeValues _rateRange;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    final List<int> rates = widget.tasks.map((Task task) => task.rate).toList()
      ..sort();
    final double minRate = rates.isEmpty ? 0 : rates.first.toDouble();
    final double maxRate = rates.isEmpty ? 1 : rates.last.toDouble();

    _minRate = minRate;
    _maxRate = maxRate <= minRate ? minRate + 1 : maxRate;
    _categoryId = widget.initialFilter.categoryId;

    final RangeValues? initialRange = widget.initialFilter.rateRange;
    if (initialRange == null) {
      _rateRange = RangeValues(_minRate, _maxRate);
    } else {
      final double start = initialRange.start
          .clamp(_minRate, _maxRate)
          .toDouble();
      final double end = initialRange.end.clamp(_minRate, _maxRate).toDouble();
      _rateRange = start <= end
          ? RangeValues(start, end)
          : RangeValues(_minRate, _maxRate);
    }
  }

  void _reset() {
    Navigator.of(context).pop(const _TaskFilter());
  }

  void _apply() {
    Navigator.of(context)
        .pop(_TaskFilter(categoryId: _categoryId, rateRange: _rateRange));
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Tugas', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Text('Kategori', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _categoryChip(
                  label: 'Semua',
                  selected: _categoryId == null,
                  onSelected: () => setState(() => _categoryId = null),
                ),
                for (final Category category in widget.categories)
                  _categoryChip(
                    label: category.name,
                    selected: _categoryId == category.id,
                    onSelected: () {
                      setState(() {
                        _categoryId = _categoryId == category.id
                            ? null
                            : category.id;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: Text('Tarif', style: textTheme.titleMedium)),
                Text(
                  '${formatRupiah(_rateRange.start.round())} - '
                  '${formatRupiah(_rateRange.end.round())}',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
            RangeSlider(
              values: _rateRange,
              min: _minRate,
              max: _maxRate,
              divisions: 20,
              labels: RangeLabels(
                formatRupiah(_rateRange.start.round()),
                formatRupiah(_rateRange.end.round()),
              ),
              activeColor: AppColors.accent,
              inactiveColor: AppColors.divider,
              onChanged: (RangeValues values) {
                setState(() => _rateRange = values);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppSpacing.primaryButtonHeight,
                    child: OutlinedButton(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.button),
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: PrimaryButton(label: 'Terapkan', onPressed: _apply),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.accent,
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.divider),
      checkmarkColor: AppColors.textPrimary,
      labelStyle: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
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
            maxLines: 2,
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
