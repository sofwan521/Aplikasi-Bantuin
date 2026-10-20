import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/task.dart';
import '../routes/app_routes.dart';
import '../services/task_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/verified_avatar_chip.dart';

/// Halaman peta statis berisi sebaran tugas dan kartu info tugas terpilih.
class MapPage extends StatefulWidget {
  const MapPage({super.key, this.repository});

  /// Repository opsional agar mudah diganti saat memakai API atau diuji.
  final TaskRepository? repository;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final TaskRepository _repository;
  late Future<List<Task>> _tasksFuture;
  String? _selectedTaskId;

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

  void _selectTask(Task task) {
    setState(() {
      _selectedTaskId = task.id;
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
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Direkomendasikan Untukmu',
            maxLines: 1,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
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
                    'Memuat peta...',
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

          final Task selectedTask = tasks.firstWhere(
            (Task task) => task.id == _selectedTaskId,
            orElse: () => tasks.first,
          );

          return Column(
            children: [
              Expanded(
                child: _MapCanvas(
                  tasks: tasks,
                  selectedTaskId: selectedTask.id,
                  onTaskTap: _selectTask,
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.sm,
                    AppSpacing.screen,
                    AppSpacing.md,
                  ),
                  child: _TaskInfoCard(
                    task: selectedTask,
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(AppRoutes.detail, arguments: selectedTask);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Peta statis dengan avatar pemosting yang diposisikan dari lat/lng.
class _MapCanvas extends StatelessWidget {
  const _MapCanvas({
    required this.tasks,
    required this.selectedTaskId,
    required this.onTaskTap,
  });

  final List<Task> tasks;
  final String selectedTaskId;
  final ValueChanged<Task> onTaskTap;

  static const double _avatarSize = 46;
  static const double _mapPadding = 12;

  @override
  Widget build(BuildContext context) {
    final List<_TaskSpot> spots = _buildSpots(tasks);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double usableWidth = math.max(
          0,
          constraints.maxWidth - _avatarSize - _mapPadding * 2,
        );
        final double usableHeight = math.max(
          0,
          constraints.maxHeight - _avatarSize - _mapPadding * 2,
        );
        final Size mapSize = Size(usableWidth, usableHeight);

        final List<Offset> positions = spots
            .map(
              (_TaskSpot spot) =>
                  Offset(spot.x * usableWidth, spot.y * usableHeight),
            )
            .toList();
        _spreadOverlappingAvatars(positions, mapSize);

        return Stack(
          fit: StackFit.expand,
          children: [
            const _MapBackground(),
            for (int index = 0; index < spots.length; index++)
              Positioned(
                left: _mapPadding + positions[index].dx,
                top: _mapPadding + positions[index].dy,
                child: _MapAvatar(
                  task: spots[index].task,
                  isSelected: spots[index].task.id == selectedTaskId,
                  onTap: () => onTaskTap(spots[index].task),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Menggeser avatar yang berdekatan agar tidak saling menumpuk.
void _spreadOverlappingAvatars(List<Offset> positions, Size size) {
  const double minDistance = _MapCanvas._avatarSize + 10;
  const int maxIterations = 100;

  for (int iteration = 0; iteration < maxIterations; iteration++) {
    bool moved = false;

    for (int first = 0; first < positions.length; first++) {
      for (int second = first + 1; second < positions.length; second++) {
        Offset delta = positions[second] - positions[first];
        final double distance = delta.distance;

        if (distance >= minDistance) {
          continue;
        }

        if (distance < 0.001) {
          final double angle = ((first * 1.7) + (second * 2.3)) % (2 * math.pi);
          delta = Offset(math.cos(angle), math.sin(angle)) * (minDistance / 2);
        } else {
          delta = delta * ((minDistance - distance) / distance / 2);
        }

        final Offset nextFirst = _clampToMap(positions[first] - delta, size);
        final Offset nextSecond = _clampToMap(positions[second] + delta, size);

        if ((nextFirst - positions[first]).distanceSquared > 0.01 ||
            (nextSecond - positions[second]).distanceSquared > 0.01) {
          moved = true;
        }

        positions[first] = nextFirst;
        positions[second] = nextSecond;
      }
    }

    if (!moved) {
      break;
    }
  }
}

/// Menjaga posisi avatar tetap berada di dalam area peta.
Offset _clampToMap(Offset position, Size size) {
  return Offset(
    position.dx.clamp(0.0, size.width).toDouble(),
    position.dy.clamp(0.0, size.height).toDouble(),
  );
}

/// Menghitung posisi avatar dari rentang koordinat seluruh tugas.
List<_TaskSpot> _buildSpots(List<Task> tasks) {
  double minLat = tasks.first.latitude;
  double maxLat = tasks.first.latitude;
  double minLng = tasks.first.longitude;
  double maxLng = tasks.first.longitude;

  for (final Task task in tasks) {
    minLat = math.min(minLat, task.latitude);
    maxLat = math.max(maxLat, task.latitude);
    minLng = math.min(minLng, task.longitude);
    maxLng = math.max(maxLng, task.longitude);
  }

  final double latRange = maxLat - minLat;
  final double lngRange = maxLng - minLng;

  return tasks
      .map((Task task) {
        final double x = lngRange == 0
            ? 0.5
            : ((task.longitude - minLng) / lngRange).clamp(0.0, 1.0).toDouble();
        final double y = latRange == 0
            ? 0.5
            : (1 - (task.latitude - minLat) / latRange)
                  .clamp(0.0, 1.0)
                  .toDouble();
        return _TaskSpot(task: task, x: x, y: y);
      })
      .toList(growable: false);
}

/// Pasangan tugas dan posisi relatifnya pada peta.
class _TaskSpot {
  const _TaskSpot({required this.task, required this.x, required this.y});

  final Task task;
  final double x;
  final double y;
}

/// Latar peta dari aset lokal dengan fallback gambar jalan sederhana.
class _MapBackground extends StatelessWidget {
  const _MapBackground();

  static const String _assetPath = 'assets/images/map.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _MapPlaceholder(),
    );
  }
}

/// Placeholder peta berupa bidang abu dengan garis jalan sederhana.
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _RoadPainter());
  }
}

/// Menggambar bidang abu dan beberapa garis jalan sederhana.
class _RoadPainter extends CustomPainter {
  const _RoadPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.placeholder);

    final Paint blockPaint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.45);
    final Paint parkPaint = Paint()
      ..color = AppColors.verified.withValues(alpha: 0.10);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.06,
          size.height * 0.08,
          size.width * 0.24,
          size.height * 0.16,
        ),
        const Radius.circular(10),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.68,
          size.height * 0.12,
          size.width * 0.22,
          size.height * 0.18,
        ),
        const Radius.circular(10),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.12,
          size.height * 0.62,
          size.width * 0.26,
          size.height * 0.20,
        ),
        const Radius.circular(10),
      ),
      blockPaint,
    );

    final Paint roadPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    final Paint roadLinePaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final Path horizontalRoad = Path()
      ..moveTo(-20, size.height * 0.34)
      ..lineTo(size.width * 0.30, size.height * 0.28)
      ..lineTo(size.width * 0.58, size.height * 0.48)
      ..lineTo(size.width + 20, size.height * 0.42);
    canvas.drawPath(horizontalRoad, roadPaint);
    canvas.drawPath(horizontalRoad, roadLinePaint);

    final Path verticalRoad = Path()
      ..moveTo(size.width * 0.30, -20)
      ..lineTo(size.width * 0.36, size.height * 0.40)
      ..lineTo(size.width * 0.28, size.height * 0.68)
      ..lineTo(size.width * 0.34, size.height + 20);
    canvas.drawPath(verticalRoad, roadPaint);
    canvas.drawPath(verticalRoad, roadLinePaint);

    final Path diagonalRoad = Path()
      ..moveTo(size.width + 20, size.height * 0.72)
      ..lineTo(size.width * 0.58, size.height * 0.82)
      ..lineTo(size.width * 0.10, size.height + 20);
    canvas.drawPath(diagonalRoad, roadPaint);
    canvas.drawPath(diagonalRoad, roadLinePaint);
  }

  @override
  bool shouldRepaint(covariant _RoadPainter oldDelegate) => false;
}

/// Avatar bulat pemosting pada peta.
class _MapAvatar extends StatelessWidget {
  const _MapAvatar({
    required this.task,
    required this.isSelected,
    required this.onTap,
  });

  final Task task;
  final bool isSelected;
  final VoidCallback onTap;

  static const double _size = _MapCanvas._avatarSize;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: task.posterName,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.surface,
                    width: 3,
                  ),
                  boxShadow: AppShadows.card,
                ),
                child: ClipOval(child: _avatarContent(context)),
              ),
              if (task.isVerified)
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.verified,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 11,
                      color: AppColors.surface,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarContent(BuildContext context) {
    if (task.posterPhotoUrl.isEmpty) {
      return _fallbackAvatar(context);
    }

    return Image.network(
      task.posterPhotoUrl,
      width: _size,
      height: _size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _fallbackAvatar(context),
    );
  }

  Widget _fallbackAvatar(BuildContext context) {
    final String initial = task.posterName.trim().isEmpty
        ? '?'
        : task.posterName.trim().characters.first.toUpperCase();

    return Container(
      color: AppColors.accent,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Kartu info tugas terpilih di bawah peta.
class _TaskInfoCard extends StatelessWidget {
  const _TaskInfoCard({required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.transparent,
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VerifiedAvatarChip(
                name: task.posterName,
                avatarUrl: task.posterPhotoUrl,
                rating: task.rating,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                task.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _formatDistance(task.distanceMeters),
                      style: textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    _formatRupiah(task.rate),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tampilan saat tidak ada tugas yang bisa ditampilkan di peta.
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
              Icons.map_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Belum ada tugas di peta',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tugas yang tersedia akan tampil di sini.',
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

/// Mengubah jarak meter menjadi teks yang mudah dibaca.
String _formatDistance(int meters) {
  if (meters < 1000) {
    return '$meters m dari kamu';
  }

  final String value = (meters / 1000).toStringAsFixed(1).replaceAll('.', ',');
  return '$value km dari kamu';
}
